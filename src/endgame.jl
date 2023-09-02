#%%
using Chess

const SS_ALL = SS_FILE_A ∪ SS_FILE_B ∪ SS_FILE_C ∪ SS_FILE_D ∪ SS_FILE_E ∪ SS_FILE_F ∪ SS_FILE_G ∪ SS_FILE_H

"""
Generate all possible KP vs K endgames:
    1. The white king can be on any square.
    2. The white pawn can be on any square except
        rank 1, rank 8 and the king's square.
    3. The black king can be on any square except:
        white king or pawn's square
        square attacked by the white king or pawn
"""
function kp_k_endgames()::Array{String}
    count = 0
    results = []
    for wk_sq ∈ SS_ALL
        for wp_sq ∈ SS_ALL - SS_RANK_1 - SS_RANK_8 - wk_sq
            for bk_sq ∈ SS_ALL - (kingattacks(wk_sq) ∪ pawnattacks(WHITE, wp_sq)) - wk_sq - wp_sq
                count += 1
                b = emptyboard()
                Chess.putpiece!(b, Piece(WHITE, KING), wk_sq)
                Chess.putpiece!(b, Piece(WHITE, PAWN), wp_sq)
                Chess.putpiece!(b, Piece(BLACK, KING), bk_sq)
                results = push!(results, fen(b))

            end
        end
    end

    return results
end

games = kp_k_endgames()

#%%

using Chess.UCI

engine = runengine("stockfish")
mpvsearch(fromfen(games[1]), engine, depth=30, pvs=1)

#%%

function score(fen::String)::Score
    b = fromfen(fen)
    mpv = mpvsearch(b, engine, depth=30, pvs=1)
    return mpv[1].score
end

map(score, games)