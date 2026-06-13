# ==============================================================================
# SCRIPT DE ANÁLISIS ESTADÍSTICO AVANZADO PARA SCOUTING DE CENTRALES
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. CARGA DE LIBRERÍAS Y PREPARACIÓN DE DATOS
# ------------------------------------------------------------------------------
library(mgcv)      # Para modelos aditivos mixtos generalizados (GAMM)
library(jagsUI)    # Para la aproximación Bayesiana (MCMC)
library(ggplot2)   # Visualización avanzada
library(gridExtra) # Composición de gráficos
library(caret)     # Validación cruzada
library(knitr)     # Formateo de tablas elegantes

# Carga del banco de datos real de scouting
datos <- read_csv("outputs/tables/scouting_dashboard.csv")
datos <- na.omit(datos)

# Configuración correcta de tipos de variables según su naturaleza futbolística
datos$Player       <- as.factor(datos$Player)
datos$Squad        <- as.factor(datos$Squad)
datos$League       <- as.factor(datos$League)
datos$role_profile <- as.factor(datos$role_profile)

# Transformación de la variable respuesta: pass_completion es un porcentaje (0-100).
# Para usar una distribución Beta (la más adecuada para proporciones continuas), 
# la transformamos a escala (0, 1). Acotamos levemente para evitar extremos estrictos (0 o 1).
datos$y_beta <- datos$pass_completion / 100
datos$y_beta <- ifelse(datos$y_beta >= 1, 0.999, ifelse(datos$y_beta <= 0, 0.001, datos$y_beta))

# Adicionalmente, guardamos el logit directo para análisis exploratorios visuales
datos$logit_pass <- qlogis(datos$y_beta)

# Variables continuas predictoras (Métricas de rendimiento e Índice de Progresión)
datos$progression_index <- as.numeric(datos$progression_index)
datos$defending_score   <- as.numeric(datos$defending_score)
datos$Age               <- as.numeric(datos$Age)

# ------------------------------------------------------------------------------
# 2. ANÁLISIS EXPLORATORIO DINÁMICO
# ------------------------------------------------------------------------------
cat("\n--- [1] RESUMEN ESTADÍSTICO MUESTRAL ---\n")
print(summary(datos[, c("pass_completion", "progression_index", "defending_score", "Age")]))

# Tabla de frecuencias por Liga y Perfil Táctico
cat("\n--- [2] DISTRIBUCIÓN POR LIGAS Y ROLES ---\n")
print(table(datos$League))
print(table(datos$role_profile))

# Matriz de correlación lineal entre métricas continuas
cat("\n--- [3] MATRIZ DE CORRELACIÓN DE PEARSON ---\n")
print(cor(datos[, c("pass_completion", "progression_index", "defending_score", "Age")]))

# Gráfico Exploratorio: Tendencias LOESS (No paramétricas) en escala Logit
p1 <- ggplot(datos, aes(x = progression_index, y = logit_pass, color = role_profile)) +
  geom_point(alpha = 0.6) + geom_smooth(method = "loess", se = FALSE) +
  labs(title = "Logit(Pase) vs Índice de Progresión", x = "Progression Index", y = "Logit(Pass %)") +
  theme_minimal()

p2 <- ggplot(datos, aes(x = defending_score, y = logit_pass, color = role_profile)) +
  geom_point(alpha = 0.6) + geom_smooth(method = "loess", se = FALSE) +
  labs(title = "Logit(Pase) vs Score Defensivo", x = "Defending Score", y = "Logit(Pass %)") +
  theme_minimal()

# Mostrar gráficos exploratorios (descomentar para visualizar en RStudio)
# grid.arrange(p1, p2, nrow = 2)

# ------------------------------------------------------------------------------
# 3. SELECCIÓN Y ESPECIFICACIÓN DE MODELOS (FRECUENTISTA - GAMM BETA)
# ------------------------------------------------------------------------------
cat("\n--- [4] AJUSTE DE MODELOS ADITIVOS MIXTOS (FAMILIA BETA) ---\n")

# M0: Modelo Base Aditivo (Suavizados independientes + Efecto aleatorio de la Liga)
mod0 <- gam(y_beta ~ role_profile + s(progression_index, k = 5) + s(defending_score, k = 5) + 
              s(League, bs = "re"), 
            family = betar(link = "logit"), data = datos, method = "REML")

# M1: Modelo con Interacción No Lineal (Tensor product entre Progresión y Defensa)
mod1 <- gam(y_beta ~ role_profile + te(progression_index, defending_score, k = c(4,4)) + 
              s(League, bs = "re"), 
            family = betar(link = "logit"), data = datos, method = "REML")

# M2: Modelo con Interacción Paramétrica Lineal (Multiplicativa clásica)
mod2 <- gam(y_beta ~ role_profile + progression_index * defending_score + 
              s(League, bs = "re"), 
            family = betar(link = "logit"), data = datos, method = "REML")

# M3: Modelo Basal GLM (Sin componentes aditivos ni efectos aleatorios de estructura)
mod3 <- gam(y_beta ~ role_profile + progression_index * defending_score, 
            family = betar(link = "logit"), data = datos, method = "REML")

# Construcción dinámica de la tabla de comparación estructural
tabla_seleccion <- data.frame(
  Modelo = c("M0: Aditivo Puro", "M1: Interacción Tensor", "M2: Interacción Lineal", "M3: GLM Basal"),
  edf    = round(c(sum(mod0$edf), sum(mod1$edf), sum(mod2$edf), sum(mod3$edf)), 1),
  AIC    = round(c(AIC(mod0), AIC(mod1), AIC(mod2), AIC(mod3)), 1),
  Deviance_Expl = paste0(round(c(summary(mod0)$dev.expl, summary(mod1)$dev.expl, 
                                 summary(mod2)$dev.expl, summary(mod3)$dev.expl) * 100, 1), "%")
)
print(tabla_seleccion)

# Validación de supuestos del modelo seleccionado (M2 en este caso por parsimonia/AIC)
cat("\n--- DIAGNÓSTICO DEL MODELO SELECCIONADO (M2) ---\n")
gam.check(mod2)

# ------------------------------------------------------------------------------
# 4. APROXIMACIÓN BAYESIANA DEL MODELO SELECCIONADO (JAGS)
# ------------------------------------------------------------------------------
cat("\n--- [5] PREPARANDO ESTIMACIÓN BAYESIANA EN JAGS ---\n")

# Para el modelo Bayesiano de la variable continua Beta, usaremos la parametrización
# clásica de la distribución Beta en JAGS: p ~ dbeta(alpha, beta)
# donde alpha = mu * phi  y  beta = (1 - mu) * phi. (phi es el parámetro de precisión).

# Estandarización preliminar de covariables para asegurar una óptima convergencia MCMC
datos$prog_std <- as.numeric(scale(datos$progression_index))
datos$def_std  <- as.numeric(scale(datos$defending_score))

# Crear matriz de diseño dummy para el factor 'role_profile' (5 niveles -> 4 variables dummy)
# Esto evita problemas de indexación de factores complejos en los bucles de JAGS
X_role <- model.matrix(~ role_profile, data = datos)[, -1] # Quitamos el intercepto

datos_jags <- list(
  n          = nrow(datos),
  y          = datos$y_beta,
  prog       = datos$prog_std,
  def        = datos$def_std,
  X_role     = X_role,
  n_roles    = ncol(X_role),
  league     = as.numeric(datos$League),
  n_leagues  = length(unique(datos$League))
)

# Escritura del archivo del modelo JAGS adaptado a una distribución Beta genuina
cat(file = "ModeloScouting_Beta.jags", "
model {
  for (i in 1:n) {
    # Distribución Beta para variables continuas acotadas (0,1)
    y[i] ~ dbeta(alpha[i], beta[i])
    
    # Reparametrización basada en la media (mu) y la precisión (phi)
    alpha[i] <- mu[i] * phi
    beta[i]  <- (1 - mu[i]) * phi
    
    # Enlace Logit para la media de precisión de pase
    logit(mu[i]) <- beta0 + 
                    beta_prog * prog[i] + 
                    beta_def * def[i] + 
                    beta_int * (prog[i] * def[i]) + 
                    inprod(beta_role[], X_role[i, ]) +
                    b_league[league[i]]
  }
  
  # Efectos Aleatorios por Liga (Estructura Jerárquica)
  for (j in 1:n_leagues) {
    b_league[j] ~ dnorm(0, tau_league)
  }
  
  # Priors no informativas para los coeficientes de rendimiento
  beta0     ~ dnorm(0, 0.01)
  beta_prog ~ dnorm(0, 0.01)
  beta_def  ~ dnorm(0, 0.01)
  beta_int  ~ dnorm(0, 0.01)
  
  # Priors para los coeficientes del perfil de rol táctico
  for(r in 1:n_roles) {
    beta_role[r] ~ dnorm(0, 0.01)
  }
  
  # Parámetro de precisión global de la distribución Beta
  phi ~ dgamma(0.1, 0.1)
  
  # Hiperpriors para el efecto aleatorio de la liga
  tau_league <- pow(sd_league, -2)
  sd_league  ~ dunif(0, 5)
}
")

# Parámetros a monitorizar, condiciones iniciales y ejecución de las cadenas MCMC
parametros_bayes <- c("beta0", "beta_prog", "beta_def", "beta_int", "beta_role", "sd_league", "phi")

inits_bayes <- function() {
  list(
    beta0     = rnorm(1, 0, 0.1),
    beta_prog = rnorm(1, 0, 0.1),
    beta_def  = rnorm(1, 0, 0.1),
    beta_int  = rnorm(1, 0, 0.1),
    beta_role = rnorm(ncol(X_role), 0, 0.1),
    phi       = runif(1, 10, 50),
    sd_league = runif(1, 0.1, 1)
  )
}

cat("\n--- EJECUTANDO SAMPLER MCMC EN JAGS... ---\n")
resul_bayesiano <- jags(
  data = datos_jags, inits = inits_bayes, parameters.to.save = parametros_bayes,
  model.file = "ModeloScouting_Beta.jags",
  n.chains = 3, n.iter = 20000, n.burnin = 5000, n.thin = 5, parallel = TRUE
)

# Imprimir resultados del ajuste bayesiano (Rhats, medias y de desvíos)
print(resul_bayesiano)

# ------------------------------------------------------------------------------
# 5. VALIDACIÓN CRUZADA POBLACIONAL (5-FOLD CV)
# ------------------------------------------------------------------------------
cat("\n--- [6] EVALUACIÓN DE CAPACIDAD PREDICTIVA (5-FOLD CV) ---\n")
set.seed(42)
K <- 5
folds <- createFolds(datos$y_beta, k = K, list = TRUE)
mae_vector <- c()

for (i in 1:K) {
  test_idx   <- folds[[i]]
  train_df   <- datos[-test_idx, ]
  test_df    <- datos[test_idx, ]
  
  # Ajuste intermedio en el conjunto de entrenamiento
  mod_cv <- gam(y_beta ~ role_profile + progression_index * defending_score + s(League, bs = "re"), 
                family = betar(link = "logit"), data = train_df, method = "REML")
  
  # Predicción poblacional pura excluyendo el efecto de grupo (League) para evaluar robustez
  predicciones <- predict(mod_cv, newdata = test_df, type = "response", exclude = "s(League)")
  
  # Error Absoluto Medio transformado de nuevo a la escala original de porcentaje (0-100)
  mae_vector[i] <- mean(abs((test_df$y_beta * 100) - (predicciones * 100)), na.rm = TRUE)
}

cat("MAE Promedio en Validación Cruzada (escala % de pase):", round(mean(mae_vector), 3), "%\n")

# ------------------------------------------------------------------------------
# 6. VISUALIZACIÓN FINAL DE LA SUPERFICIE DE RESPUESTA INTERACTIVA
# ------------------------------------------------------------------------------
# Generamos un grid sintético para mapear el comportamiento del acierto en el pase 
grid_pred <- expand.grid(
  progression_index = seq(min(datos$progression_index), max(datos$progression_index), length = 100),
  defending_score   = seq(min(datos$defending_score), max(datos$defending_score), length = 100),
  role_profile      = levels(datos$role_profile)[1], # Fijamos un rol basal
  League            = levels(datos$League)[1]        # Fijamos una liga basal
)

# Extraer predicciones de probabilidad marginal
grid_pred$pred_pass <- predict(mod2, newdata = grid_pred, type = "response", exclude = "s(League)") * 100

grafico_superficie <- ggplot(grid_pred, aes(x = progression_index, y = defending_score, z = pred_pass)) +
  geom_contour_filled() +
  labs(title = "Superficie de Predicción: % de Acierto en el Pase",
       x = "Índice de Progresión de Balón", y = "Puntuación de Eficacia Defensiva", fill = "Precisión (%)") +
  theme_minimal()

# Mostrar gráfico final de contornos interactivos (descomentar para graficar)
# print(grafico_superficie)

cat("\n--- SCRIPT COMPLETADO CON ÉXITO ---\n")