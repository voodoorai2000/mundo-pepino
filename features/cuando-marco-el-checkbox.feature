Característica: marco el checkbox

  Escenario: Marco (o desmarco) una casilla (*checkbox*)  
  ########################################################################
  # Patrón:
  #   Cuando marco (la/el)? _checkbox_id_
  #
  # Ejemplos:
  #   Cuando desmarco color_verde
  #   Cuando marco el "color verde"
  #
  # Descripción:
  #   Selecciona el checkbox con el identificador indicado admitiendo
  # comillas opcionalmente. 
  # 
  #   Sobre el identificador facilitado se sustituyen los espacios por 
  # guiones bajos ("_").
  #
  ########################################################################
    # Pre-checking
    Cuando visito la portada
         Y pincho en el botón "Galleta de la fortuna"
    Entonces veo el tag div#check_seleccionado con el valor "Seleccionado"
           Y no veo el tag div#check_sin_seleccionar con el valor "Sin seleccionar"

    # Let's go for it...
    Cuando visito la portada
         Y desmarco el check_seleccionado
         Y marco el check sin seleccionar
         Y pincho en el botón "Galleta de la fortuna"
    Entonces no veo el tag div#check_seleccionado con el valor "Seleccionado"
           Y veo el tag div#check_sin_seleccionar con el valor "Sin seleccionar"