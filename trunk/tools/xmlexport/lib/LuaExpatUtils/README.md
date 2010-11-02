# Utiltiies for working with LOM XML Documents

`lxp.doc` is a module that provides useful features for working with XML formats in [LOM format](http://www.keplerproject.org/luaexpat/lom.html) as used by the [LuaExpat](http://www.keplerproject.org/luaexpat) project from [Kepler](http://www.keplerproject.org).

It is based on [stanza.lua](http://hg.prosody.im/trunk/file/4621c92d2368/util/stanza.lua), which is part of the [Prosody](http://prosody.im) IM server by Mathew Wild and Waqas Hussain. Although the origiinal used a another representation for XML snippets, it was straightforward to modify for LOM.

The pattern matching is inspired by Scott Volkes' [tamale](http://http://github.com/silentbicycle/tamale) library, and by subsequent discussions with him.

## Pretty-Printing LOM and LOM generation

`lxp.doc` provides a flexible XML pretty-printer for LOM documents:

    local doc = require 'lxp.doc'
    local lom = require 'lxp.lom'
    local d = lom.parse '<abc a1="A1" a2="A2"><ef>hello</ef></abc>'
    print(doc.tostring(d,'','  '))

which gives the following output, with an initial indent of '' and a per-element indent of '  '.

    <abc a1='A1' a2='A2'>
      <ef>hello</ef>
    </abc>

Setting the _attribute indent_ with `doc.tostring(d,'','  ','  ')` we get:

    <abc
      a1='A1'
      a2='A2'>
      <ef>hello</ef>
    </abc>

`stanza.lua` implements a very cool pattern for building LOM documents which I have carried over:

    > = doc.new 'top' : addtag 'child' : text 'alice'
    <top><child>alice</child></top>
    > = doc.new 'top' : addtag 'child' : text 'alice' :up(): addtag 'child' : text 'bo'
    <top><child>alice</child><child>bo</child></top>

(The key idea here is the 'move up one level' method `up()`)  You can see more examples of this style in the `stanza` [documentation](http://prosody.im/doc/developers/util/stanza).

`lxp.doc` provides an alterative XML builder; this is from `test-doc.lua`:

    d1 = doc.new 'children' :
        addtag 'child' :
        addtag 'name' : text 'alice' : up() : addtag 'age' : text '5' : up() : addtag('toy',{type='fluffy'}) : up() :
        up() :
        addtag 'child':
        addtag 'name' : text 'bob' : up() : addtag 'age' : text '6' : up() : addtag('toy',{type='squeaky'})

    local children,child,toy,name,age = doc.tags 'children,child,toy,name,age'

    d2 = children {
        child {name 'alice', age '5', toy {type='fluffy'}},
        child {name 'bob', age '6', toy {type='squeaky'}}
    }

    assert(doc.compare(d1,d2))

This is inspired by the `htmlify` function used by [Orbit](http://keplerproject.github.com/orbit/) to simplify HTML generation, except that no function environment magic is used; the `tags` function returns a set of _constructors_ for elements of the given tag names.

## Parsing XML

`lxp.doc` provides a convenience function `doc.parse(xml,is_file,use_basic)`. If `is_file` is `true` then `xml` is interpreted as a file, otherwise as a string.  By default, it will use `lxp.lom.parse`, unless LuaExpat is not installed, or `use_basic` is explicitly `true`.  If your XML needs are light and uncomplicated - for instance, using it as a configuration file format - then `lxp.doc` provides a pure Lua XML parser based on code originally by Roberto Ierusalimschy, modified to use LOM format. (See the lua-users [wiki](http://lua-users.org/wiki/LuaXml) page.)

`doc.basic_parse` is not intended to be a proper conforming parser (it's only sixty lines) but it handles simple kinds of documents that do not have comments or DTD directives. It is intelligent enough to ignore the `<?xml` directive and that is about it.

## LOM document model methods

`lxp.doc` does not provide a W3C DOM model, but rather uses a simplified API which is arguably more Lua-friendly.  If `d` is a LOM node, then `d:child_with_name 'child'` would return the first child element with tag name 'child', if it exists.  `d:get_elements_with_name 'child'` would return a Lua table containing all elements with that name, to any depth.  `d:children()` provides an iterator over all child nodes, including text, and `d:childtags()` iterates over all child elements.

`d:walk(depth_first,callback)` provides another way of visiting all the elements in a document; if `depth_first` is `true`, it will first visit the children before the parent. `callback` will be passed the tag name and the node itself.

## Templates and Matching

Continuing with the parent/child example above, the `subst` method will use a _LOM template_ to generate a document:

    templ = child {name '$name', age '$age', toy{type='$toy'}}

    d3 = children(templ:subst{
        {name='alice',age='5',toy='fluffy'},
        {name='bob',age='6',toy='squeaky'}
    })

    assert(doc.compare(d2,d3))

A template is a LOM document containing at least some strings of the form `$NAME` or `$NUMBER`. `subst()` will copy this template and sub

f `subst()` is given a simple table of name-value pairs and will create a copy of the template substituting the values for the names.  Numerical keys are treated as array indices:

    > d = doc.new 'top' : addtag 'child' : text '$child'
    > = d
    <top><child>$child</child></top>
    > = d:subst{child = 'johnny'}
    <top><child>johnny</child></top>
    > d = doc.parse "<child age='$1'>$2</child>"
    > = d:subst {10,'johnny'}
    <child age='10'>johnny</child>
    

If it is given a list of such tables, it will create a list of the substitutions. If that list has a `tag` field, then it's used as the top-level element:
    
    > r =  d:subst {tag='children',{10,'don'},{9,'alice'}}
    > = doc.tostring(r,'',' ')
    <children>
     <child age='10'>don</child>
     <child age='9'>alice</child>
    </children>


Matching goes in the opposite direction.  We have a document, and would like to extract values from it using a pattern.

A common use of this is parsing the XML result of API queries.  The [(undocumented) Google Weather API](http://blog.programmableweb.com/2010/02/08/googles-secret-weather-api/) is a good example. Grabbing the result of `http://www.google.com/ig/api?weather=Johannesburg,ZA" we get something like this, after pretty-printing:

    <xml_api_reply version='1'>
      <weather module_id='0' tab_id='0' mobile_zipped='1' section='0' row='0' mobile_row='0'>
        <forecast_information>
          <city data='Johannesburg, Gauteng'/>
          <postal_code data='Johannesburg,ZA'/>
          <latitude_e6 data=''/>
          <longitude_e6 data=''/>
          <forecast_date data='2010-10-02'/>
          <current_date_time data='2010-10-02 18:30:00 +0000'/>
          <unit_system data='US'/>
        </forecast_information>
        <current_conditions>
          <condition data='Clear'/>
          <temp_f data='75'/>
          <temp_c data='24'/>
          <humidity data='Humidity: 19%'/>
          <icon data='/ig/images/weather/sunny.gif'/>
          <wind_condition data='Wind: NW at 7 mph'/>
        </current_conditions>
        <forecast_conditions>
          <day_of_week data='Sat'/>
          <low data='60'/>
          <high data='89'/>
          <icon data='/ig/images/weather/sunny.gif'/>
          <condition data='Clear'/>
        </forecast_conditions>
        ....
       </weather>
    </xml_api_reply>

Assume that the above XML has been read into `google`. The idea is to write a pattern looking like a template, and use it to extract some values of interest:

    t = [[
      <weather>
        <current_conditions>
          <condition data='$condition'/>
          <temp_c data='$temp'/>
        </current_conditions>
      </weather>
    ]]

    local res, ret = google:match(t)
    pretty.dump(ret,res)

And the output is:

    true	{
      condition = "Clear",
      temp = "24"
    }

The `match` method can be passed a LOM document or some text, which will be parsed first. Note that `$NUMBER` is treated specially as a numerical index, so that `$1` is the first element of the resulting array, etc.

Patterns can contain an extra bit of syntax; we often want to match a pattern for multiple values: If the matching element is enclosed in `{{...}}` then the match will be used repeatedly.

    t = [[
      <weather>
        {{<forecast_conditions>
          <day_of_week data='$day'/>
          <low data='$low'/>
          <high data='$high'/>
          <condition data='$condition'/>
        </forecast_conditions>}}
      </weather>
    ]]

Please note that we're not capturing `data` attributes from every element, `lxp.doc` uses partial matching - as long as the matching elements are in order it will ignore mismatches.

The resulting table capture is:

    {
      {
        low = "60",
        high = "89",
        day = "Sat",
        condition = "Clear"
      },
      {
        low = "53",
        high = "86",
        day = "Sun",
        condition = "Clear"
      },
      {
        low = "57",
        high = "87",
        day = "Mon",
        condition = "Clear"
      },
      {
        low = "60",
        high = "84",
        day = "Tue",
        condition = "Clear"
      }
    }

Another example is parsing one of the many configuration files which litter the hard drives of our computers.  `serviceproviders.xml` is a large catalogue of all the mobile broadband providers currently known, used by the Gnome NetworkManager.  To get a list of all the providers by country, you can use the following template:

    <serviceproviders>
    {{<country code="$country">
        {{<provider>
            <name>$name</name>
        </provider>}}
    </country>}}
    </serviceproviders>

You will get a list of all countries; here is the entry for Brazil:

     ...
     {
        {
          name = "Brasil Telecom"
        },
        {
          name = "Claro"
        },
        {
          name = "CTBC"
        },
        {
          name = "Oi"
        },
        {
          name = "TIM"
        },
        {
          name = "Velox"
        },
        {
          name = "Vivo"
        },
        country = "br"
      },
      ...

That's not an ideal output format, but there some tricks to allow you to shape the output better:

    <serviceproviders>
    {{<country code="$_">
        {{<provider>
            <name>$0</name>
        </provider>}}
    </country>}}
    </serviceproviders>

There are some special cases here - `$_` means use this value for the key used to insert the tablet into the result, and `$0` is a special case of the `$N` pattern: it means collapse the table into the single value which is `T[0]`.

      br = {
        "Brasil Telecom",
        "Claro",
        "CTBC",
        "Oi",
        "TIM",
        "Velox",
        "Vivo"
      },

## Future Work

The major question which has to be answered is 'Does the Lua world need another XML toolkit?'. I hope that `lxp.doc` at least provides some useful utilities for working with the LOM standard.  It is not intended as a one-stop shop, unless your XML needs are simple.  At 670 lines, it is probably a bit big for a single module and may need splitting into logical parts. Having three distinct ways to build LOM documents is probably overkill.

`lxp.lom` tends to work with the common case of XML _data_ representations, where text elements only appear as the single child of tags.  It would not be a good match for XHTML processing.

The `{{...}}` notation for patterns is arbitrary; advanced users may need more control over the match process, say in specifying exact sequence matching.  Adding more 'syntax' to an XML file may lead to ugly patterns.

The `match()` method does suggest that a Lua-like generalization, `gmatch()` would be useful and idiomatic, as would `gsub()`.

    dn = d:gsub([[
        <parent>
         {{child age='$age'>$name</child>}}
        </parent>
        ]],[[
        <parent>
         {{<child age='$age' name='$name'/>}}
        </parent>
        ]]
    )

This suggests that there can be useful symmetry between patterns and templates.
