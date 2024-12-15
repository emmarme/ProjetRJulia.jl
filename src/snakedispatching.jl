using Random
using Printf

# Paramètres du jeu
const WIDTH = 20
const HEIGHT = 10
const INITIAL_LENGTH = 5
const DIRECTIONS = Dict(
    'Z' => (0, -1),  # Haut
    'S' => (0, 1),   # Bas
    'Q' => (-1, 0),  # Gauche
    'D' => (1, 0)    # Droite
)

# Type abstrait pour le serpent
abstract type AbstractSnake end

# Structure de données pour un serpent classique
struct Snake <: AbstractSnake
    body::Vector{Tuple{Int, Int}}  # Corps du serpent
    direction::Char  # Direction actuelle
end

# Structure de données pour un serpent avec un corps plus long
struct LongSnake <: AbstractSnake
    body::Vector{Tuple{Int, Int}}  # Corps du serpent
    direction::Char  # Direction actuelle
    speed::Float64  # Vitesse du serpent
end

# Fonction pour initialiser un serpent normal
function init_snake()
    return Snake([(i, 5) for i in reverse(1:INITIAL_LENGTH)], 'D')  # Direction: Droite
end

# Fonction pour initialiser un serpent plus long avec une vitesse
function init_long_snake()
    return LongSnake([(i, 5) for i in reverse(1:INITIAL_LENGTH)], 'D', 1.0)  # Direction: Droite, vitesse: 1.0
end

# Fonction pour générer la nourriture
function spawn_food(snake::AbstractSnake)
    food_position = rand(1:WIDTH), rand(1:HEIGHT)
    while food_position in snake.body  # S'assurer que la nourriture ne spawn pas sur le serpent
        food_position = rand(1:WIDTH), rand(1:HEIGHT)
    end
    return food_position
end

# Fonction pour afficher le jeu
function draw_game(snake::AbstractSnake, food::Tuple{Int, Int})
    println("\033[2J")  # Efface l'écran
    for y in 1:HEIGHT
        for x in 1:WIDTH
            if (x, y) in snake.body
                print("O")
            elseif (x, y) == food
                print("X")
            else
                print(".")
            end
        end
        println()
    end
    println("Press 'q' to quit.")
end

# Fonction pour déplacer le serpent
function move_snake(snake::AbstractSnake)
    if snake isa Snake
        head = snake.body[1]
        dx, dy = DIRECTIONS[snake.direction]
        new_head = (head[1] + dx, head[2] + dy)
        new_body = [new_head; snake.body[1:end-1]]  # Mettre à jour le corps du serpent
        return Snake(new_body, snake.direction)  # Retourner une nouvelle instance de Snake
    elseif snake isa LongSnake
        head = snake.body[1]
        dx, dy = DIRECTIONS[snake.direction]
        new_head = (head[1] + dx * snake.speed, head[2] + dy * snake.speed)  # Vitesse modifiée
        new_body = [new_head; snake.body[1:end-1]]
        return LongSnake(new_body, snake.direction, snake.speed)  # Retourner une nouvelle instance de LongSnake
    end
end

# Fonction pour vérifier les collisions
function check_collision(snake::AbstractSnake, food::Tuple{Int, Int})
    head = snake.body[1]
    if head in snake.body[2:end]  # Vérifier si la tête touche le corps
        return true  # Collision avec le corps
    end
    if head[1] < 1 || head[1] > WIDTH || head[2] < 1 || head[2] > HEIGHT
        return true  # Collision avec les bords
    end
    if head == food
        return false, true  # Manger la nourriture
    end
    return false, false  # Pas de collision
end

# Fonction pour lire l'entrée clavier de manière non-bloquante
function get_input()
    input = readline(stdin, keep=true)  # Lire l'entrée de l'utilisateur
    if !isempty(input)  # Vérifier si l'entrée n'est pas vide
        return input[1]  # Retourner le premier caractère de la chaîne
    else
        return ""  # Sinon, retourner une chaîne vide
    end
end

# Fonction principale du jeu
function game_loop()
    snake = init_long_snake()  # Utilisation d'un serpent plus long avec vitesse
    food = spawn_food(snake)
    game_over = false

    while !game_over
        draw_game(snake, food)

        # Lire l'entrée clavier sans bloquer
        input = get_input()
        if input == "q"
            println("Game Over!")
            break
        end

        # Changer la direction uniquement si elle est valide (et ne va pas à l'opposé)
        if input in keys(DIRECTIONS)
            if input == 'Z' && snake.direction != 'S'
                snake = LongSnake(snake.body, 'Z', snake.speed)  # Créer une nouvelle instance de Snake
            elseif input == 'S' && snake.direction != 'Z'
                snake = LongSnake(snake.body, 'S', snake.speed)
            elseif input == 'Q' && snake.direction != 'D'
                snake = LongSnake(snake.body, 'Q', snake.speed)
            elseif input == 'D' && snake.direction != 'Q'
                snake = LongSnake(snake.body, 'D', snake.speed)
            end
        end

        # Déplacer le serpent (cela va créer une nouvelle instance de Snake)
        snake = move_snake(snake)

        # Vérifier les collisions
        collision, ate_food = check_collision(snake, food)
        if collision
            println("Game Over! You hit something.")
            game_over = true
        elseif ate_food
            println("Yum! You ate the food!")
            # Ajouter une nouvelle partie au serpent
            snake.body = [(food[1], food[2]); snake.body]
            food = spawn_food(snake)  # Spawner une nouvelle nourriture
        end

        sleep(0.1)  # Mettre une pause entre chaque itération (réduire la vitesse du jeu)
    end
end

# Lancer le jeu
game_loop()
test