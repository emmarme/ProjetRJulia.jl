using MLJModels
using DecisionTree
using ScikitLearn: fit!, predict
using CSV
using DataFrames
using CategoricalArrays
using MLJ


function load_data2()
    data_path = joinpath(@__DIR__, "../data/Athletes_summer_games.csv")
    data = CSV.read(data_path, DataFrame)

    #Garde que la gymnastique
    databis = filter(row -> row[:Sport] in ["Artistic Gymnastics","Gymnastics"], data)

    #Garde uniquement les 5 derniers JO
    filtered_data = filter(row -> row[:Year] >= 2008 && row[:Year] <= 2024, databis)
    dropmissing!(filtered_data)
    filtered_data.Medal=replace(filtered_data.Medal, missing =>"No medal")
    filtered_data.Medal = replace(filtered_data.Medal, "Gold" => 1, "Silver" => 2, "Bronze" => 3, "No medal" => 0)

    filtered_data = filter(row -> !(row.Event in ["Gymnastics Women's Team All-Around","Women's Team", "Gymnastics Men's Team All-Around","Men's Team"]), filtered_data)

    #Variable Event nettoyage
    filtered_data.Event = categorical(filtered_data.Event)
    replacements = Dict(
    "Gymnastics Women's Uneven Bars" => "Barres asymétriques",
    "Women's Uneven Bars" => "Barres asymétriques",
    "Gymnastics Women's Horse Vault" => "Saut Femme",
    "Women's Vault" => "Saut Femme",
    "Gymnastics Women's Floor Exercise" => "Sol Femme",
    "Women's Floor Exercise" => "Sol Femme",
    "Gymnastics Women's Balance Beam" => "Poutre Femme",
    "Women's Balance Beam" => "Poutre Femme",
    "Gymnastics Men's Rings" => "Anneaux homme",
    "Men's Rings" => "Anneaux homme",
    "Gymnastics Men's Floor Exercise" => "Sol homme",
    "Men's Floor Exercise" => "Sol homme",
    "Gymnastics Men's Horse Vault" => "Saut homme",
    "Men's Vault" => "Saut homme",
    "Gymnastics Men's Parallel Bars" => "Barres parallèles hommes",
    "Men's Parallel Bars" => "Barres parallèles hommes",
    "Gymnastics Men's Pommelled Horse" => "Cheval d'Arçons",
    "Men's Pommel Horse" => "Cheval d'Arçons",
    "Gymnastics Men's Horizontal Bar" => "Barre fixe",
    "Men's Horizontal Bar" => "Barre fixe",
    "Gymnastics Women's Individual All-Around" => "Concours Individuel feminin",
    "Women's All-Around" => "Concours Individuel feminin",
    "Gymnastics Men's Individual All-Around" => "Concours Individuel masculin",
    "Men's All-Around" => "Concours Individuel masculin"
    )

    # Appliquer les remplacements dans la colonne `Event`
    for (old_value, new_value) in replacements
        replace!(filtered_data.Event, old_value => new_value)
    end

    #Transforme les variables en catégorielle
    filtered_data.Sex=categorical(filtered_data.Sex)
    filtered_data.NOC=categorical(filtered_data.NOC)
    filtered_data.Name=categorical(filtered_data.Name)

    #Nettoyage de la var Age
    filtered_data=dropmissing(filtered_data, :Age)
    filtered_data.Age = Int.(filtered_data.Age) 
    
    # #Nombre de médailles par athlètes 
    # total_Medals=combine(groupby(filtered_data, :Name), [:GoldMedals, :SilverMedals, :BronzeMedals] .=> sum)
    # filtered_data = leftjoin(filtered_data, total_Medals, on=:Name)


    return filtered_data
end

  
function train_model2(filtered_data)
    function one_hot_encode(column, colname_prefix)
        unique_vals = unique(column)
        return DataFrame([Symbol("$(colname_prefix)_$(val)") => (column .== val) for val in unique_vals])
    end

    # Sélectionner les colonnes et encoder
    X = select(filtered_data, [:Age])  # Inclut la colonne `Age` seule pour l'instant
    X = hcat(X, one_hot_encode(filtered_data[!, :Sex], "Sex"))
    X = hcat(X, one_hot_encode(filtered_data[!, :Event], "Event"))
    X = hcat(X, one_hot_encode(filtered_data[!, :NOC], "NOC"))

    y=filtered_data.Medal

    #Diviser en ensemble d'entrainement et test
    train, test = partition(eachindex(y),0.7)

    #Separer ensemble entrainement et test
    X_train, X_test = Matrix(X[train, :]), Matrix(X[test, :])
    y_train, y_test = y[train], y[test]
    
    #Chargement du modèle
    model = RandomForestClassifier(n_trees=100, max_depth=5)
    fit!(model, X_train, y_train)

    #Prediction
    y_pred= predict(model, X_test)

    return model, y_test, y_pred

end

function evaluate_model2(y_test,y_pred)
    #Calcul et affichage de la précision
    accuracy=sum(y_test .== y_pred) / length(y_test)
    println("Accuracy", accuracy)

    #Calcul et affichage de la matrice de confusion
    cm =confusion_matrix(y_test,y_pred)
    println("Confusion Matrice", cm)

    #Calcul de la précision, f1 score et recall
    recall_score=recall(y_pred,y_test)
    println("Recall : ", recall_score)
    f1_score=f1score(y_pred,y_test)
    println("F1 score : ", f1_score)
    
    return accuracy, cm, recall_score,f1_score

end

