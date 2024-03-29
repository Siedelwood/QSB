return [[
> local no_spaces = ldoc.no_spaces
> local use_li = ldoc.use_li
> local display_name = ldoc.display_name
> local iter = ldoc.modules.iter
> local function M(txt,item) return ldoc.markup(txt,item,ldoc.plain) end
> local nowrap = ldoc.wrap and '' or 'nowrap'
> if module then
# $(ldoc.module_typename(module)) <code>$(module.name)</code>
$(M(module.summary,module))
$(M(module.description,module))
> end
> local lev = ldoc.level or 2
> local lev1,lev2 = ('#'):rep(lev),('#'):rep(lev+1)
> for kind, items in module.kinds() do
>  local kitem = module.kinds:get_item(kind)
>  if kitem then

$(lev1) $(ldoc.descript(kitem))

>      if kitem.usage then
**Beispiel:**
$(ldoc.prettify(kitem.usage[1]))
>      end
>  end
>   for item in items() do

$(lev2) $(ldoc.display_name(item))

$(ldoc.descript(item))

>  if item.params and #item.params > 0 then
>      local subnames = module.kinds:type_of(item).subnames
>      if subnames then

**Parameter:**

>      end
| Name | Typ | Beschreibung |
|---|---|---|
>      for parm in iter(item.params) do
>          local param,sublist = item:subparam(parm)
>          if sublist then
$(sublist) $(M(item.params.map[sublist],item))
>          end
>          for p in iter(param) do
>              local name,tp,def = item:display_name_of(p), ldoc.typename(item:type_of_param(p)), item:default_of_param(p)
| $(name) | $(tp) | $(item.params.map[p]) |
> -- $(M(item.params.map[p],item))
>              if def == true then
*optional*
>              elseif def then
*default* $(def))
>              end
>              if item:readonly(p) then
*readonly*
>              end
>          end
>      end -- for
>   end -- if params

>   if item.retgroups then local groups = item.retgroups

**Rückgabe:**

| Typ | Beschreibung |
|---|---|
>       for i,group in ldoc.ipairs(groups) do local li,il = use_li(group)
>           for r in group:iter() do local type, ctypes = item:return_type(r); local rt = ldoc.typename(type)
>               if rt ~= '' then
| $(rt) | $(M(r.text,item))$(il) |
>               else
| - | $(M(r.text,item))$(il) |
>               end
>           end -- for r
>       if i < #groups then

<h3>Or</h3>

>       end
>   end -- for group
>   end -- if returns

>   if item.see then
>       local li,il = use_li(item.see)

### Verwandte Themen:
<ul>

>       for see in iter(item.see) do

$(li)<a href="$(ldoc.href(see))">$(see.label)</a>$(il)

>       end -- for

</ul>

>   end -- if see

>   if item.usage then
>       local li,il = use_li(item.usage)

**Beispiel:**
<ul>

>       for usage in iter(item.usage) do

$(li)<pre class="example">$(ldoc.prettify(usage))</pre>$(il)

>       end -- for

</ul>

>   end -- if usage

> end
> end
]]
