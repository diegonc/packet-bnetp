local asserteq = require 'pl.test'.asserteq
local doc = require 'lxp.doc'
xml = 'joburg.xml'
local d = doc.parse(xml,true)

t1 = [[
  <weather>
    <current_conditions>
      <condition data='$condition'/>
      <temp_c data='$temp'/>
    </current_conditions>
  </weather>
]]

t2 = [[
  <weather>
    {{<forecast_conditions>
      <day_of_week data='$day'/>
      <low data='$low'/>
      <high data='$high'/>
      <condition data='$condition'/>
    </forecast_conditions>}}
  </weather>
]]

function match(t,xpect)
    local res,ret = d:match(t)
    asserteq(res,xpect)
  --print(ret,pretty.write(res))
end

match(t1,{
  condition = "Clear", 
  temp = "24", 
} )

match(t2,{
  {
    low = "60", 
    high = "89", 
    day = "Sat", 
    condition = "Clear", 
  },
  {
    low = "53", 
    high = "86", 
    day = "Sun", 
    condition = "Clear", 
  },
  {
    low = "57", 
    high = "87", 
    day = "Mon", 
    condition = "Clear", 
  },
  {
    low = "60", 
    high = "84", 
    day = "Tue", 
    condition = "Clear", 
  }
})


