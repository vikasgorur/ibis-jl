### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ a04d9316-0ed3-11ee-345f-7f02d7bbc40e
using Chess

# ╔═╡ 664e0e5d-a8eb-4dad-a1a3-6889a48d2c6e
b = fromfen("r1bqkbnr/ppp2ppp/3p4/4P3/3N1p2/PPN5/2P1Q1PP/R1B1KB1R b KQkq - 0 8")

# ╔═╡ fc36eea1-2707-4843-93cd-d220c0c136f5
const PIECE_VALUES = Dict{PieceType, Int64}(
	PAWN => 1,
	KNIGHT => 3,
	BISHOP => 3,
	ROOK => 5,
	QUEEN => 9,
	KING => 255
)

# ╔═╡ 8368c01b-e4f6-486f-b577-22be6f96c60b
pieces(b, WHITE)

# ╔═╡ be63f8c5-1781-4beb-a4e9-b0c156921648
function material(b::Board, c::PieceColor)::Int
	sum(map(sq -> PIECE_VALUES[ptype(pieceon(b, sq))], squares(pieces(b, c))))
end

# ╔═╡ d57d4dfc-5e04-42ab-b9d9-c86d490ee1f9
material(b, BLACK)

# ╔═╡ 46f83d1b-5006-490f-aa30-9d0f14b6668c
function arebrothers(b::Board, sq1::Square, sq2::Square)::Bool
	pieceon(b, sq1) == pieceon(b, sq2)
end

# ╔═╡ 453e4909-6275-44a4-827a-b43c2a5c7774
arebrothers(b, squarefromstring("f4"), squarefromstring("f7"))

# ╔═╡ 9c534828-63c8-4137-991f-b6c760d65ecd
"""
	samefilepawns(b::Board, sq::Square)::SquareSet

Returns the square set of all pawns of the same color as the pawn on `sq`. Note that this includes the pawn on `sq` itself.
"""
function samefilepawns(b::Board, sq::Square)::SquareSet
	@assert ptype(pieceon(b, sq)) == PAWN

	ret = SS_EMPTY
	for s ∈ filesquares(sq)
		if arebrothers(b, s, sq)
			ret += s
		end
	end
	ret
end

# ╔═╡ 21e5de7d-b838-4d15-af9f-63dc768eb7b8
samefilepawns(b, squarefromstring("f4"))

# ╔═╡ 00b8c709-9891-43a4-bdb7-11b0eab553c4
"""
	neighborfilespawns(b::Board, sq::Square)::SquareSet

"""
function neighborfilespawns(b::Board, sq::Square)::SquareSet
	@assert ptype(pieceon(b, sq)) == PAWN

	ret = SS_EMPTY
	neighbors = SS_EMPTY
	for sq_ ∈ [sq + DELTA_W, sq + DELTA_E] # left, right
		if tostring(sq_) != "??"
			neighbors = neighbors ∪ filesquares(sq_)
		end
	end
	
	for s ∈ neighbors
		if arebrothers(b, s, sq)
			ret += s
		end
	end
	ret
end

# ╔═╡ b2027688-1cb5-4064-a6f0-0b105330ddba
neighborfilespawns(b, squarefromstring("g7"))



# ╔═╡ 5a693574-d59f-4873-8ff1-3fd1ebf31c43
"""
	isdoubled(b::Board, sq::Square)::Bool

Returns true if the pawn on `sq` is a doubled pawn (= if there is another pawn
on the same file).
"""
function isdoubled(b::Board, sq::Square)::Bool
	@assert ptype(pieceon(b, sq)) == PAWN

	squarecount(samefilepawns(b, sq)) > 1
end


# ╔═╡ e2219e82-9ad1-47ac-bfc4-14c7ed424f8c
isdoubled(b, squarefromstring("f4"))

# ╔═╡ 80606e10-194a-4de0-b65c-9123c41fec02
"""
	isisolated(b::Board, sq::Square)::Bool

Returns true if the pawn on `sq` is an isolated pawn (= there are no pawns on the neighboring files).
"""
function isisolated(b::Board, sq::Square)::Bool
	@assert ptype(pieceon(b, sq)) == PAWN

	squarecount(neighborfilespawns(b, sq)) == 0
end

# ╔═╡ e7d4a2ce-0075-4f9b-9e29-b264384fdeca
isisolated(b, squarefromstring("e5"))

# ╔═╡ 18efc1d5-f5f1-4c90-9d5a-dffa279382e6
for sq in neighborfilespawns(b, squarefromstring("c2"))
	print(rank(sq))
end

# ╔═╡ 0abad85c-b934-45fd-bc2d-93036f7ea2ae
function pawnquality(b::Board, c::PieceColor, pred)
	sum(map(sq -> pred(b, sq),
			squares(pieces(b, c, PAWN))))
end

# ╔═╡ bc3a3961-f314-4168-a0c1-889f58f9f2b5
doubledpawns(b::Board, c::PieceColor) = pawnquality(b, c, isdoubled)

# ╔═╡ e31602cf-8faa-4086-8139-8dfe7dffd77d
isolatedpawns(b::Board, c::PieceColor) = pawnquality(b, c, isisolated)

# ╔═╡ 4dc55c1a-1073-4b50-aba8-f0b00d2d70a3
isolatedpawns(b, BLACK)

# ╔═╡ cfeb64a6-2c39-4935-ac12-7656b5bf8487
function shannoneval(b::Board)::Float64
	m = materialvalue(material(b, WHITE)) - materialvalue(material(b, BLACK))
	bk = backwardpawns(b, WHITE) - backwardpawns(b, BLACK)
	i = isolatedpawns(b, WHITE) - isolatedpawns(b, BLACK)
	d = doubledpawns(b, WHITE) - doubledpawns(b, BLACK)

	m - 0.5*(bk + i + d)
end

# ╔═╡ 1487271a-2f17-4960-9548-f1d57c018f4f
m = material(b, WHITE)

# ╔═╡ d67de9b5-abea-4976-8e7a-09d84b085f33
shannoneval(b)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Chess = "717200cc-f167-4fd3-b4bf-b5e480529844"

[compat]
Chess = "~0.7.5"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.1"
manifest_format = "2.0"
project_hash = "e0b1918b272f7e716fd07ea65babb52a599ce41e"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Chess]]
deps = ["Artifacts", "Crayons", "Dates", "DefaultApplication", "Formatting", "Hiccup", "HypertextLiteral", "InteractiveUtils", "JSON", "Printf", "Random", "SQLite", "StaticArrays", "StatsBase", "UUIDs"]
git-tree-sha1 = "8eb910e96ca126046b5ab83b417297de669581b3"
uuid = "717200cc-f167-4fd3-b4bf-b5e480529844"
version = "0.7.5"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "7a60c856b9fa189eb34f5f8a6f6b5529b7942957"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.6.1"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.2+0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DBInterface]]
git-tree-sha1 = "9b0dc525a052b9269ccc5f7f04d5b3639c65bca5"
uuid = "a10d1c49-ce27-4219-8d33-6db1a4562965"
version = "2.5.0"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DefaultApplication]]
deps = ["InteractiveUtils"]
git-tree-sha1 = "c0dfa5a35710a193d83f03124356eef3386688fc"
uuid = "3f0dd361-4fe0-5fc6-8523-80b14ec94d85"
version = "1.1.0"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Hiccup]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "6187bb2d5fcbb2007c39e7ac53308b0d371124bd"
uuid = "9fb69e20-1954-56bb-a84f-559cc56a8ff7"
version = "0.2.2"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "c3ce8e7420b3a6e071e0fe4745f5d4300e37b13f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.24"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OrderedCollections]]
git-tree-sha1 = "d321bf2de576bf25ec4d3e4360faca399afca282"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "5a6ab2f64388fd1175effdf73fe5933ef1e0bac0"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.0"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "9673d39decc5feece56ef3940e5dafba15ba0f81"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.1.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "7eb1686b4f04b82f96ed7a4ea5890a4f0c7a09f1"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SQLite]]
deps = ["DBInterface", "Random", "SQLite_jll", "Serialization", "Tables", "WeakRefStrings"]
git-tree-sha1 = "eb9a473c9b191ced349d04efa612ec9f39c087ea"
uuid = "0aa819cd-b072-5ff4-a722-6bc24af294d9"
version = "1.6.0"

[[deps.SQLite_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "4619dd3363610d94fb42a95a6dc35b526a26d0ef"
uuid = "76ed43ae-9a5d-5a62-8c75-30186b810ce8"
version = "3.42.0+0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "c60ec5c62180f27efea3ba2908480f8055e17cee"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "832afbae2a45b4ae7e831f86965469a24d1d8a83"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.26"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "45a7769a04a3cf80da1c1c7c60caf932e6f4c9f7"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.6.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "1544b926975372da01227b382066ab70e574a3ec"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═a04d9316-0ed3-11ee-345f-7f02d7bbc40e
# ╠═664e0e5d-a8eb-4dad-a1a3-6889a48d2c6e
# ╠═fc36eea1-2707-4843-93cd-d220c0c136f5
# ╠═8368c01b-e4f6-486f-b577-22be6f96c60b
# ╠═be63f8c5-1781-4beb-a4e9-b0c156921648
# ╠═d57d4dfc-5e04-42ab-b9d9-c86d490ee1f9
# ╠═46f83d1b-5006-490f-aa30-9d0f14b6668c
# ╠═453e4909-6275-44a4-827a-b43c2a5c7774
# ╠═9c534828-63c8-4137-991f-b6c760d65ecd
# ╠═21e5de7d-b838-4d15-af9f-63dc768eb7b8
# ╠═00b8c709-9891-43a4-bdb7-11b0eab553c4
# ╠═b2027688-1cb5-4064-a6f0-0b105330ddba
# ╠═5a693574-d59f-4873-8ff1-3fd1ebf31c43
# ╠═e2219e82-9ad1-47ac-bfc4-14c7ed424f8c
# ╠═80606e10-194a-4de0-b65c-9123c41fec02
# ╠═e7d4a2ce-0075-4f9b-9e29-b264384fdeca
# ╠═18efc1d5-f5f1-4c90-9d5a-dffa279382e6
# ╠═0abad85c-b934-45fd-bc2d-93036f7ea2ae
# ╠═bc3a3961-f314-4168-a0c1-889f58f9f2b5
# ╠═e31602cf-8faa-4086-8139-8dfe7dffd77d
# ╠═4dc55c1a-1073-4b50-aba8-f0b00d2d70a3
# ╠═cfeb64a6-2c39-4935-ac12-7656b5bf8487
# ╠═1487271a-2f17-4960-9548-f1d57c018f4f
# ╠═d67de9b5-abea-4976-8e7a-09d84b085f33
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
