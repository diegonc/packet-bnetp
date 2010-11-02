require "api.utils"

require "doc"

--[[
--  casewhen
--
--  Selects a block of fields from a list when it's associated condition
--  is true.
--
--  Walks though the list of pairs received as argument sequentially evaluating
--  the first element and if it was true executing the second element of the
--  pair as a block of fields.
--
--  Only one block is executed.
--
--  This function actually emulates if (..) .. elseif (..) sequence. Use Cond.always()
--  as condition if you want to use final else.
--
--  Table call: { {condition, block}, ... }
--    @par condition Function that returns true if the block should be
--                   used given the current state.
--    @par block     Block of fields that will be executed when condition
--                   is true.
--
--]]
function casewhen (...)
	local tests
	if (#arg == 1) and arg[1].tests then
		tests = arg[1].tests
	else
		tests = {}
		-- XXX: little hack to allow both syntax for calling a function
		--      ( f() and f {} )
		if #arg == 1 and type(arg[1][1])=="table" then arg = arg[1] end
		for k, v in ipairs(arg) do
			local test = make_args_table_with_positional_map(
				{"condition", "block"}, v)
			tests[k] = test
		end
	end

	local node = doc.new "casewhen"
	for _, v in ipairs(tests) do
		local block = v.block
		v.block = nil

		local case = doc.new ("case", v)
		for _, v in pairs(block) do
			case:add_direct_child(v)
		end
		node:add_direct_child(case)
	end
	return node
end

--[[
--  when
--
--  Selects a block of fields from two alternatives acording to a condition
--  function result.
--
--  Emulates if(..) then .. else .. sequence
--
--  Only one block is executed.
--
--  Quick call: ( condition, block, otherwise )
--  Table call: { condition=..., block=..., otherwise=... }
--    @par condition Function that returns true if the block should be
--                   used given the current state.
--    @par block     Block of fields that will be executed when condition
--                   is true.
--    @par otherwise Block of fields used when condition is false.
--
--]]
function when (...)
	local args = make_args_table_with_positional_map(
			{"condition", "block", "otherwise"}, unpack(arg))
	if args.params then
		error(package.loaded.debug.traceback())
	end

	local block = args.block
	local other = args.otherwise

	args.block = nil
	args.otherwise = nil

	local node = doc.new ("when", args)
	local true_node = doc.new "do"
	local false_node = doc.new "otherwise"

	for _, v in pairs(block) do
		true_node:add_direct_child(v)
	end
	node:add_direct_child(true_node)

	if other then
		for _,v in pairs(other) do
			false_node:add_direct_child(v)
		end
		node:add_direct_child(false_node)
	end
	return node
end
