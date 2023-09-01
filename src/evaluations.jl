using Chess

export eval_1

"""
    eval_1(b::Board)::Float64

Evaluates the position based on material and pawn structure.
"""
function eval_1(b::Board)::Float64
    material(b, WHITE) - material(b, BLACK) + 0.5*(
        doubledpawns(b, WHITE) - doubledpawns(b, BLACK) +
        isolatedpawns(b, WHITE) - isolatedpawns(b, BLACK)
    )
end