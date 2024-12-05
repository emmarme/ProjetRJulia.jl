using Pkg
using CSV
using DataFrames
using Plots
using StatsPlots
using StatsBase
using MLJ
using DecisionTree
using ScikitLearn: fit!, predict

#Fonction pour load le dataset quelque soit la ou il est
function load_data()
    # Trouve le chemin du dataset dans le package
    data_path = joinpath(@__DIR__, "../data/data.csv")

    data=CSV.read(data_path, DataFrame)

    select!(data, Not([:id,:Column33]))

    data.diagnosis = parse.(Int, replace.(data.diagnosis, "M" => "1", "B" => "0"))

    return data
end

#visualisation
counts=countmap(data.diagnosis)
histogram(data.radius_mean)
pie(counts)

function train_model(data)
    #on selectionne notre X et y
    X=select(data,Not([:diagnosis]))
    y=data.diagnosis

    #Diviser en ensemble d'entrainement et test
    train, test = partition(eachindex(y),0.7,shuffle=true)

    #Separer ensemble entrainement et test
    X_train, X_test = Matrix(X[train, :]), Matrix(X[test, :])
    y_train, y_test = y[train], y[test]

    #Chargement du modèle
    model = RandomForestClassifier(n_trees=100,max_depth=6)
    fit!(model, X_train, y_train)

    #Prediction
    y_pred= predict(model, X_test)

    return model, y_test, y_pred
end 


function evaluate_model(y_test,y_pred)
    #Calcul et affichage de la précision
    accuracy=sum(y_test .== y_pred) / length(y_test)
    println("Accuracy: ", accuracy)

    #Calcul et affichage de la matrice de confusion
    cm =confusion_matrix(y_test,y_pred)
    println("Confusion Matrice : ", cm)

    #Calcul de la précision, f1 score et recall
    recall_score=recall(y_pred,y_test)
    println("Recall : ", recall_score)
    
    f1_score=f1score(y_pred,y_test)
    println("F1 score : ", f1_score)

    return accuracy, cm, recall_score,f1_score

end
