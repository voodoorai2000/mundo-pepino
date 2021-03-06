veo_o_no = '(?:no )?(?:veo|debo ver|deber[ií]a ver)'

Entonces /^(#{veo_o_no}) el texto (.+)?$/i do |should, text|
  eval('response.body.send(shouldify(should))') =~ /#{Regexp.escape(text.to_unquoted.to_translated)}/m
end

leo_o_no = '(?:no )?(?:leo|debo leer|deber[íi]a leer)'
Entonces /^(#{leo_o_no}) el texto (.+)?$/i do |should, text|
  begin
    HTML::FullSanitizer.new.sanitize(response.body).send(shouldify(should)) =~ /#{Regexp.escape(text.to_unquoted.to_translated)}/m
  rescue Spec::Expectations::ExpectationNotMetError
    webrat.save_and_open_page
    raise
  end
end

Entonces /^(#{veo_o_no}) los siguientes textos:$/i do |should, texts|
  texts.raw.each do |row|
    Entonces "#{should} el texto #{row[0]}"
  end
end

Entonces /^(#{veo_o_no}) (?:en )?(?:el selector|la etiqueta|el tag) (["'].+?['"]|[^ ]+)(?:(?: con)? el (?:valor|texto) )?["']?([^"']+)?["']?$/ do |should, tag, value |
  lambda {
    if value
      response.should have_tag(tag.to_unquoted, /.*#{value.to_translated}.*/i)
    else
      response.should have_tag(tag.to_unquoted)
    end
  }.send(not_shouldify(should), raise_error)  
end

Entonces /^(#{veo_o_no}) (?:las|los) siguientes (?:etiquetas|selectores):$/i do |should, texts|
  check_contents, from_index = texts.raw[0].size == 2 ? [true, 1] : [false, 0]
  texts.raw[from_index..-1].each do |row|
    if check_contents
      Entonces "#{should} el selector \"#{row[0]}\" con el valor \"#{row[1]}\""
    else
      Entonces "#{should} el selector \"#{row[0]}\""
    end
  end
end



Entonces /^(#{veo_o_no}) un enlace (?:a|para) (.+)?$/i do |should, pagina|
  lambda {
    href = relative_page(pagina) || pagina.to_unquoted.to_url 
    response.should have_tag('a[href=?]', href)
  }.send(not_shouldify(should), raise_error)
end


Entonces /^(#{veo_o_no}) marcad[ao] (?:la casilla|el checkbox)? ?(.+)$/ do |should, campo|
  field_labeled(unquote(campo)).send shouldify(should), be_checked
end

Entonces /^(#{veo_o_no}) (?:una|la) tabla (?:(["'].+?['"]|[^ ]+) )?con (?:el|los) (?:siguientes? )?(?:valore?s?|contenidos?):$/ do |should, table_id, valores|
  table_id = "##{table_id.to_unquoted}" if table_id
  shouldified = shouldify(should)
  response.send shouldified, have_selector("table#{table_id}")

  if have_selector("table#{table_id} tbody").matches?(response.body)
    start_row = 1
    tbody = "tbody"
  else
    start_row = 2
    tbody = ""
  end

  valores.raw[1..-1].each_with_index do |row, i|
    row.each_with_index do |cell, j|
      response.send shouldified, 
      have_selector("table#{table_id} #{tbody} tr:nth-child(#{i+start_row}) td:nth-child(#{j+1})") { |td|
        td.inner_text.should =~ /#{cell == '.*' ? cell : Regexp.escape((cell||"").to_translated)}/
      }
    end
  end
end

Entonces /^(#{veo_o_no}) un formulario con (?:el|los) (?:siguientes? )?(?:campos?|elementos?):$/ do |should, elementos|
  shouldified = shouldify(should)
  response.send(shouldified, have_tag('form')) do
    elementos.raw[1..-1].each do |row|
      label, type = row[0].to_translated, row[1]
      case type
        when "submit":
          with_tag "input[type='submit'][value='#{label}']"
        when "radio":
          with_tag('div') do
            with_tag "label", label
            with_tag "input[type='radio']"
          end  
        when "select", "textarea":
          field_labeled(label).element.name.should == type
        else  
          field_labeled(label).element.attributes['type'].to_s.should == type
      end
    end
  end
end

#BBDD
en_bbdd_tenemos = '(?:en (?:la )?(?:bb?dd?|base de datos) tenemos|tenemos en (?:la )?(?:bb?dd?|base de datos))'
tiene_en_bbdd = '(?:tiene en (?:la )?bbdd|en (?:la )?bbdd tiene|tiene en (?:la )?base de datos|en (?:la )?base de datos tiene)'
Entonces /^#{en_bbdd_tenemos} (un|una|dos|tres|cuatro|cinco|\d+) ([^ ]+)(?: (?:llamad[oa]s? )?['"](.+)["'])?$/ do |numero, modelo, nombre|
  model = modelo.to_unquoted.to_model
  conditions = if nombre
    {:conditions => [ "#{field_for(model, 'nombre')}=?", nombre ]}
  else
    {}
  end
  resources = model.find(:all, conditions)
  resources.size.should == numero.to_number
  if resources.size > 0
    pile_up (resources.size == 1 ? resources.first : resources)
  end
end

Entonces /^(?:el|la) (.+) "(.+)" #{tiene_en_bbdd} como (.+) "(.+)"(?: \w+)?$/ do |modelo, nombre, campo, valor|
  add_resource_from_database(modelo, nombre)
  last_mentioned_should_have_value(campo, valor.to_real_value)
end

Entonces /^#{tiene_en_bbdd} como (.+) "(.+)"(?: \w+)?$/ do |campo, valor|
  last_mentioned_should_have_value(campo, valor.to_real_value)
end

Entonces /^(?:el|la) (.+) "(.+)" #{tiene_en_bbdd} una? (.+) "(.+)"$/ do |padre, nombre_del_padre, hijo, nombre_del_hijo|
  add_resource_from_database(padre, nombre_del_padre)
  last_mentioned_should_have_child(hijo, nombre_del_hijo)
end

Entonces /^#{tiene_en_bbdd} una? (.+) "(.+)"$/ do |hijo, nombre_del_hijo|
  last_mentioned_should_have_child(hijo, nombre_del_hijo)
end
