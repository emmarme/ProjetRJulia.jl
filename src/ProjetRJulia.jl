module ProjetRJulia

export load_data, train_model, evaluate_model, load_data2, train_model2, evaluate_model2, init_snake, init_snake2, init_long_snake2, spawn_food, spawn_food2, draw_game, draw_game2, move_snake, move_snake2, check_collision, check_collision2, get_input, get_input2, game_loop, game_loop2

include("breastcancer.jl")

include("medalsprediction.jl")

include("snakegame.jl")

include("snakedispatching.jl")

end
