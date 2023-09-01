using Chess

export material,
	arefellows,
	samefilepawns,
	neighborfilespawns,
	isdoubled,
	isisolated,
	doubledpawns,
	isolatedpawns

const PIECE_VALUES = Dict{PieceType, Int64}(
	PAWN => 1,
	KNIGHT => 3,
	BISHOP => 3,
	ROOK => 5,
	QUEEN => 9,
	KING => 0
)

"""
	material(b::Board, c::PieceColor) -> Int

Returns the material count for the given color.
"""
function material(b::Board, c::PieceColor)::Int
	sum(map(sq -> PIECE_VALUES[ptype(pieceon(b, sq))], squares(pieces(b, c))))
end

"""
	arefellows(b::Board, sq1::Square, sq2::Square) -> Bool

Returns true if the two squares have pieces of the same color and type.
"""
function arefellows(b::Board, sq1::Square, sq2::Square)::Bool
	pieceon(b, sq1) == pieceon(b, sq2)
end

"""
	samefilepawns(b::Board, sq::Square)::SquareSet

Returns the `SquareSet` of all pawns of the same color as the pawn on `sq`.
Note that this includes the pawn on `sq` itself.
"""
function samefilepawns(b::Board, sq::Square)::SquareSet
	@assert ptype(pieceon(b, sq)) == PAWN

	Iterators.filter(
		s -> arefellows(b, s, sq),
		filesquares(sq)
	) |> collect |> _s -> SquareSet(_s...)
end


"""
	neighborfilespawns(b::Board, sq::Square)::SquareSet

Returns the `SquareSet` of all pawns of the same color as the pawn on `sq`
that are on the neighboring files.
"""
function neighborfilespawns(b::Board, sq::Square)::SquareSet
	@assert ptype(pieceon(b, sq)) == PAWN

	neighbors = SS_EMPTY
	for sq_ ∈ [sq + DELTA_W, sq + DELTA_E] # left, right
		if tostring(sq_) != "??"
			neighbors = neighbors ∪ filesquares(sq_)
		end
	end

	Iterators.filter(
		s -> arefellows(b, s, sq),
		neighbors
	) |> collect |> _s -> SquareSet(_s...)
end

## Pawn structure functions

"""
	isdoubled(b::Board, sq::Square)::Bool

Returns true if the pawn on `sq` is a doubled pawn (= if there is another pawn
on the same file).
"""
function isdoubled(b::Board, sq::Square)::Bool
	@assert ptype(pieceon(b, sq)) == PAWN

	squarecount(samefilepawns(b, sq)) > 1
end

"""
	isisolated(b::Board, sq::Square)::Bool

Returns true if the pawn on `sq` is an isolated pawn (= there are no pawns on the neighboring files).
"""
function isisolated(b::Board, sq::Square)::Bool
	@assert ptype(pieceon(b, sq)) == PAWN

	squarecount(neighborfilespawns(b, sq)) == 0
end

"""
	doubledpawns(b::Board, c::PieceColor)::Int

Returns the number of doubled pawns for the given color.
"""
function doubledpawns(b::Board, c::PieceColor)::Int
	sum(map(sq -> isdoubled(b, sq),
			squares(pieces(b, c, PAWN)))
	)
end

"""
	isolatedpawns(b::Board, c::PieceColor)::Int

Returns the number of isolated pawns for the given color.
"""
function isolatedpawns(b::Board, c::PieceColor)::Int
	sum(map(sq -> isisolated(b, sq),
			squares(pieces(b, c, PAWN)))
	)
end