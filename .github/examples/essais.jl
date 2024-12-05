using ProjetRJulia

########################### Breast Cancer #############################

#Charger le dataset
data = ProjetRJulia.load_data()

#Entrainement et predicton du modèle pour le cancer du sein
model, y_test, y_pred=train_model(data)

# Évaluation du modèle cancer du sein
accuracy, cm, recall_score, f1_score = evaluate_model(y_test, y_pred)