local doc = require 'lxp.doc'

d = doc.new 'top' : addtag 'child' : text 'alice' : up() : addtag 'child' : text 'bob'
--print(d)

function pretty_print(d)
    print(doc.tostring(d,'','  '))
end

d = doc.new 'children' :
	addtag 'child' :
	addtag 'name' : text 'alice' : up() : addtag 'age' : text '5' : up() : addtag('toy',{type='fluffy'}) : up() :
	up() :
	addtag 'child':
	addtag 'name' : text 'bob' : up() : addtag 'age' : text '6' : up() : addtag('toy',{type='squeaky'})

--~ pretty_print(d)

local children,child,toy,name,age = doc.tags 'children,child,toy,name,age'

d1 = children {
    child {name 'alice', age '5', toy {type='fluffy'}},
    child {name 'bob', age '6', toy {type='squeaky'}}
}

--~ pretty_print(d1)
assert(doc.compare(d,d1))

templ = child {name '$name', age '$age', toy{type='$toy'}}

d2 = children(templ:subst{
    {name='alice',age='5',toy='fluffy'},
    {name='bob',age='6',toy='squeaky'}
})

assert(doc.compare(d1,d2))
--~ print(doc.tostring(d2,'','  ',' '))

--pretty_print(d2)

--~ doc.walk(d2,false,function(name,d)
--~     print(name)
--~ end)

--for c in d2:childtags() do print(c.tag) end

--~ pretty_print(doc.subst(
--~     templ,
--~     {name='jane',age='7',toy='wobbly'}
--~ ))

