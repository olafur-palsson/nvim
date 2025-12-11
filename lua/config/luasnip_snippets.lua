local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.expand_conditions")

ls.cleanup()

local function map(index, mapping)
    return f(function(args)
        local str = args[1][1]
        if type(str) ~= 'string' then
            str = ''
        end
        return mapping(str)
    end, { index })
end

function kebab_to_pascal(str)
  if type(str) ~= "string" then
    return ""
  end

  return str
    :gsub("-%a", function(match)
      return match:sub(2):upper()
    end)
    :gsub("^%l", string.upper)
end

local function pascal_to_kebab(str)
    if type(str) ~= 'string' then
        str = ''
    end
  -- Normalize separators and trim
  str = str:gsub("[^%w]", " ")      -- Replace non-alphanumerics with space
           :gsub("(%l)(%u)", "%1 %2") -- Split lower-uppercase
           :gsub("(%u)(%u%l)", "%1 %2") -- Split ALLCAPS followed by lowercase
           :gsub("%s+", "-")         -- Convert spaces to dashes
           :lower()                  -- Lowercase final result

  return str
end

local same = function(index)
    return f(function(args)
        return args[1][1]
    end, { index })
end


local function as_kebab(index)
    return d(1, function(arg)
        return pascal_to_kebab(arg[1])
    end)
end

ls.add_snippets("lua", {
	s("expand", {
		t("--expanded!"),
	}),
    s("f1",
        fmt("again {} normal {}, kebab {}, test {}", { map(1, pascal_to_kebab), i(1), f(fn, { 1 }), map(1, pascal_to_kebab)})
    )
})

local html_snippets = {
    s('ngif', fmt('*ngIf="{}"', { i(0) })),
    s('ngife', fmt('*ngIf="{}; else {}"', { i(1), i(0) })),
    s('ngfor', fmt('*ngFor="let {} of {}"', { i(1), i(0) })),
    s('ngm', fmt('[(ngModel)]="{}"', { i(0) })),
    s('ngt', fmt([[
        <ng-template #{}>
          {}
        </ng-template>
    ]], { i(1), i(0) })),
    s('ngc', fmt('[class.{}]="{}"', { i(1), i(0) })),
    s('pre', fmt('<pre>{{{{ {} | json }}}}</pre>', { i(0) })),
}

ls.add_snippets('htmlangular', html_snippets)
ls.add_snippets('html', html_snippets)

ls.add_snippets("typescript", {
	s("comp",
		fmt(
[[

    import {{ AuthStoreService }} from 'src/app/services/auth-store.service';
    import {{ DataService }} from 'src/app/services/data.service';
    import {{ Component }} from '@angular/core';{}

    @Component({{{}
      selector: 'app-{}',
      templateUrl: '{}.component.html',
      styleUrls: ['{}.component.scss'],
    }})
    export class {}Component {{
      constructor(
        public _data: DataService,
        public _auth: AuthStoreService,
      ) {{}}
    }}
]], {
                c(1, {
                    t(''),
                    t({ '', "import { SharedModule } from 'src/app/shared.module';" }),
                }),
                c(2, {
                    t(''),
                    t({ '', '  standalone: true,',  '  imports: [', '    SharedModule', '  ],' })
                }),
                map(3, pascal_to_kebab),
                map(3, pascal_to_kebab),
                map(3, pascal_to_kebab),
                i(3)
            }
        )
	),
    s('meth',
        fmt(
            [[
                {}({}) {{
                  {}
                }}
            ]], {
                i(1), i(2), i(0)
            }
        )
    ),
    s('inp',
        fmt('@Input() {}: {};', { i(1), i(0) })
    ),
    s('out',
        fmt('@Output() {} = new EventEmitter<{}>();', { i(1), i(0) })
    ),
    s('int',
        fmt([[
                export interface {} {{
                  {}
                }}
            ]], { i(1), i(0) })
    ),
    s('n', fmt('{}: number', { i(0) })),
    s('s', fmt('{}: number', { i(0) })),
    s('b', fmt('{}: boolean', { i(0) })),
})
