@testitem "Evaluations" begin
    using Chess

    initial = startboard()
    vienna_3 = fromfen("rnbqkb1r/pppp1ppp/5n2/8/4Pp2/2N5/PPPP2PP/R1BQKBNR w KQkq - 0 1")
    # Vienna Game, 1. e4 e5 2. Nc3 Nf6 3. f4 exf4
    #  r  n  b  q  k  b  -  r 
    #  p  p  p  p  -  p  p  p 
    #  -  -  -  -  -  n  -  - 
    #  -  -  -  -  -  -  -  - 
    #  -  -  -  -  P  p  -  - 
    #  -  -  N  -  -  -  -  - 
    #  P  P  P  P  -  -  P  P 
    #  R  -  B  Q  K  B  N  R 

    @test eval_1(initial) == 0.0
    @test eval_1(vienna_3) == -2.0
end