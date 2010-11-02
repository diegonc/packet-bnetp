require "api.utils"

require "doc"

do
-- Helper function to define integer api
local function define_integer(isize)
	local size = math.abs(isize)
	local typename = "int"

	if size == 8 then typename = typename .. "64" end
	if isize > 0 then typename = "u" .. typename  end
	
	if size ~= 8 then
		typename = typename .. tostring(8*size)
	end

	getfenv(2)[typename] = function(...)
		local attrs = make_args_table_with_positional_map(
				{"label", "display", "desc"}, unpack(arg))
		local vmap = valuemap(attrs.desc)

		attrs.desc = nil

		local node = doc.new(typename, attrs)
		if vmap then
			node:add_direct_child(vmap)
		end
		return node
	end
end

--[[
--  uint64
--
--  Creates a field for a 64-bits unsigned integer.
--
--  Quick call: ( label, base, valuemap )
--    @par label    Name of the field. It will be used as a label for the
--                  field's node at the dissection tree.
--    @par base     The base used to display the number.
--    @par valuemap Friendly names assigned to the valid values of the field.
--
--  Table call: { }
--
--  @see Base
--
--]]
define_integer(8)

--[[
--  uint32
--
--  Creates a field for a 32-bits unsigned integer.
--
--  Quick call: ( label, base, valuemap )
--    @par label    Name of the field. It will be used as a label for the
--                  field's node at the dissection tree.
--    @par base     The base used to display the number.
--    @par valuemap Friendly names assigned to the valid values of the field.
--
--  Table call: { }
--
--  @see Base
--
--]]
define_integer(4)

--[[
--  uint16
--
--  Creates a field for a 16-bits unsigned integer.
--
--  Quick call: ( label, base, valuemap )
--    @par label    Name of the field. It will be used as a label for the
--                  field's node at the dissection tree.
--    @par base     The base used to display the number.
--    @par valuemap Friendly names assigned to the valid values of the field.
--
--  Table call: { }
--
--  @see Base
--
--]]
define_integer(2)

--[[
--  uint8
--
--  Creates a field for a 8-bits unsigned integer.
--
--  Quick call: ( label, base, valuemap )
--    @par label    Name of the field. It will be used as a label for the
--                  field's node at the dissection tree.
--    @par base     The base used to display the number.
--    @par valuemap Friendly names assigned to the valid values of the field.
--
--  Table call: { }
--
--  @see Base
--
--]]
define_integer(1)

--[[
--  int64
--
--  Creates a field for a 64-bits signed integer.
--
--  Quick call: ( label, base, valuemap )
--    @par label    Name of the field. It will be used as a label for the
--                  field's node at the dissection tree.
--    @par base     The base used to display the number.
--    @par valuemap Friendly names assigned to the valid values of the field.
--
--  Table call: { }
--
--  @see Base
--
--]]
define_integer(-8)

--[[
--  int32
--
--  Creates a field for a 32-bits signed integer.
--
--  Quick call: ( label, base, valuemap )
--    @par label    Name of the field. It will be used as a label for the
--                  field's node at the dissection tree.
--    @par base     The base used to display the number.
--    @par valuemap Friendly names assigned to the valid values of the field.
--
--  Table call: { }
--
--  @see Base
--
--]]
define_integer(-4)

--[[
--  int16
--
--  Creates a field for a 16-bits signed integer.
--
--  Quick call: ( label, base, valuemap )
--    @par label    Name of the field. It will be used as a label for the
--                  field's node at the dissection tree.
--    @par base     The base used to display the number.
--    @par valuemap Friendly names assigned to the valid values of the field.
--
--  Table call: { }
--
--  @see Base
--
--]]
define_integer(-2)

--[[
--  int8
--
--  Creates a field for a 8-bits signed integer.
--
--  Quick call: ( label, base, valuemap )
--    @par label    Name of the field. It will be used as a label for the
--                  field's node at the dissection tree.
--    @par base     The base used to display the number.
--    @par valuemap Friendly names assigned to the valid values of the field.
--
--  Table call: { }
--
--  @see Base
--
--]]
define_integer(-1)

end
