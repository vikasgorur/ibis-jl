@testitem "Position tests" begin
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

    @test material(initial, WHITE) == 39
    @test material(initial, BLACK) == 39

    @test arefellows(initial, SQ_A2, SQ_B2) == true
    @test arefellows(initial, SQ_A1, SQ_B1) == false
    @test arefellows(initial, SQ_A8, SQ_B8) == false
    @test arefellows(initial, SQ_F7, SQ_G7) == true

    @test samefilepawns(initial, SQ_E2) == SquareSet(SQ_E2)
    @test samefilepawns(initial, SQ_H7) == SquareSet(SQ_H7)
    @test_throws AssertionError samefilepawns(initial, SQ_E1)

    @test samefilepawns(vienna_3, SQ_F4) == SquareSet(SQ_F4, SQ_F7)

    @test neighborfilespawns(initial, SQ_E2) == SquareSet(SQ_D2, SQ_F2)
    @test neighborfilespawns(initial, SQ_H7) == SquareSet(SQ_G7)
    @test neighborfilespawns(initial, SQ_A2) == SquareSet(SQ_B2)
    @test_throws AssertionError neighborfilespawns(initial, SQ_E1)

    onlypawns = fromfen("1k6/p6p/5p2/3P2p1/3P3P/3PK3/8/8 w - - 0 1")
    # -  k  -  -  -  -  -  - 
    # p  -  -  -  -  -  -  p 
    # -  -  -  -  -  p  -  - 
    # -  -  -  P  -  -  p  - 
    # -  -  -  P  -  -  -  P 
    # -  -  -  P  K  -  -  - 
    # -  -  -  -  -  -  -  - 
    # -  -  -  -  -  -  -  -     
    # Pawn structure
    @test isdoubled(initial, SQ_E2) == false
    @test isdoubled(onlypawns, SQ_D3) == true
    @test isdoubled(onlypawns, SQ_D4) == true
    @test isdoubled(onlypawns, SQ_D5) == true

    @test doubledpawns(initial, WHITE) == 0
    @test doubledpawns(onlypawns, WHITE) == 3
    @test doubledpawns(onlypawns, BLACK) == 0

    @test isisolated(initial, SQ_A2) == false
    @test isisolated(onlypawns, SQ_D3) == true
    @test isisolated(onlypawns, SQ_D4) == true
    @test isisolated(onlypawns, SQ_D5) == true
    @test isisolated(onlypawns, SQ_H4) == true
    @test isisolated(onlypawns, SQ_A7) == true

    @test isolatedpawns(initial, WHITE) == 0
    @test isolatedpawns(onlypawns, WHITE) == 4
    @test isolatedpawns(onlypawns, BLACK) == 1
end
