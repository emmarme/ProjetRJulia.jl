using ProjetRJulia

########################### Breast Cancer #############################

#Charger le dataset
data = ProjetRJulia.load_data()

#Entrainement et predicton du modèle pour le cancer du sein
model, y_test, y_pred=train_model(data)

# Évaluation du modèle cancer du sein
accuracy, cm, recall_score, f1_score = evaluate_model(y_test, y_pred)


#################### Médailles prédiction #############################

#On prépare la base de donnée et on charge
filtered_data = ProjetRJulia.load_data2()

#Entrainement et predicton du modèle
model, y_test, y_pred=train_model2(filtered_data)

# Évaluation du modèle
accuracy, cm, recall_score, f1_score = evaluate_model2(y_test, y_pred)

#Je veux dans mon résultat, le nom, la médaille gagnée et dans quelle event 
prediction = DataFrame(Name = filtered_data.Name[partition(eachindex(filtered_data.Medal), 0.7)[2]], pred_Medal = y_pred, Event = filtered_data.Event[partition(eachindex(filtered_data.Medal), 0.7)[2]])
resultat_par_evnmt = groupby(prediction, :Event)

