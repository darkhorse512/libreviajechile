// Traducciones comunes: botones, acciones genéricas, widgets compartidos,
// mensajes de feedback. La clave es EXACTAMENTE el texto original en español.

const Map<String, String> commonEn = {
  // Acciones / botones
  'Cancelar': 'Cancel',
  'Confirmar': 'Confirm',
  'Aceptar': 'Accept',
  'Guardar': 'Save',
  'Guardar cambios': 'Save changes',
  'Continuar': 'Continue',
  'Reintentar': 'Retry',
  'Cerrar': 'Close',
  'Cerrar sesión': 'Sign out',
  'Sí': 'Yes',
  'No': 'No',
  'Listo': 'Done',
  'Aceptar tarifa': 'Accept fare',
  'Guardando…': 'Saving…',
  'Cargando…': 'Loading…',
  // Ciudad / ubicación
  'Ciudad': 'City',
  'Selecciona tu ciudad': 'Select your city',
  'Buscar ciudad o región…': 'Search city or region…',
  'Busca una dirección, calle o lugar…': 'Search an address, street or place…',
  'Confirmar ubicación': 'Confirm location',
  'Confirmar origen': 'Confirm origin',
  'Confirmar destino': 'Confirm destination',
  'Buscando dirección…': 'Finding address…',
  'Mueve el mapa para elegir': 'Move the map to choose',
  'Ubicación seleccionada': 'Selected location',
  'Mi ubicación actual': 'My current location',
  'No pudimos obtener tu ubicación. Revisa los permisos.':
      "We couldn't get your location. Check your permissions.",
  'Ruta del viaje': 'Trip route',
  // Calificación
  'Enviar calificación': 'Send rating',
  'Escribe un comentario (opcional)': 'Write a comment (optional)',
  '¡Gracias por tu calificación!': 'Thanks for your rating!',
  'No se pudo guardar la calificación': "Couldn't save the rating",
  'Califica a tu {role}': 'Rate your {role}',
  // Apariencia / roles
  'Modo claro': 'Light mode',
  'Modo oscuro': 'Dark mode',
  'conductor': 'driver',
  'pasajero': 'passenger',
  'Conductor': 'Driver',
  'Pasajero': 'Passenger',
  // Idioma
  'Idioma': 'Language',
  'Automático (dispositivo)': 'Automatic (device)',
  'Selecciona un idioma': 'Select a language',
  // Navegación
  'Navegar': 'Navigate',
  'Abrir con': 'Open with',
  'Ver la ruta en el mapa': 'View the route on the map',
  'Navegación paso a paso': 'Turn-by-turn navigation',
  'No se pudo abrir Waze': "Waze couldn't be opened",
  // Notificaciones
  'Nueva solicitud de viaje': 'New trip request',
  'Nueva oferta recibida': 'New offer received',
  '¡Tu oferta fue aceptada!': 'Your offer was accepted!',
  'El pasajero te eligió. ¡Prepárate para el viaje!':
      'The passenger chose you. Get ready for the trip!',
  // Estados de viaje / rol
  'Buscando conductor': 'Finding a driver',
  'Conductor asignado': 'Driver assigned',
  'En viaje': 'On the way',
  'Completado': 'Completed',
  'Cancelado': 'Cancelled',
  'Administrador': 'Administrator',
  // Validaciones de formulario
  'Este campo': 'This field',
  '{field} es obligatorio': '{field} is required',
  'Año no válido': 'Invalid year',
  'Correo no válido': 'Invalid email',
  'Ingresa el año': 'Enter the year',
  'Ingresa la patente': 'Enter the plate',
  'Ingresa tu correo': 'Enter your email',
  'Ingresa tu nombre': 'Enter your name',
  'Ingresa tu teléfono': 'Enter your phone',
  'Ingresa una contraseña': 'Enter a password',
  'Mínimo 6 caracteres': 'At least 6 characters',
  'Nombre demasiado corto': 'Name too short',
  'Patente no válida (ej: BBBB12)': 'Invalid plate (e.g. BBBB12)',
  'Teléfono no válido': 'Invalid phone',
  // Tiempo relativo
  'recién': 'just now',
  'ayer': 'yesterday',
  'hace {n} min': '{n} min ago',
  'hace {n} h': '{n} h ago',
  'hace {n} días': '{n} days ago',
  // Recuperación de contraseña
  '¿Olvidaste tu contraseña?': 'Forgot your password?',
  'Recuperar contraseña': 'Reset password',
  'Te enviaremos un enlace a tu correo para restablecer tu contraseña.':
      "We'll email you a link to reset your password.",
  'Enviar': 'Send',
  'Te enviamos un correo para recuperar tu contraseña.':
      'We sent you an email to reset your password.',
  'No se pudo enviar el correo de recuperación.':
      "We couldn't send the recovery email.",
  'Te enviamos un código para recuperar tu contraseña.':
      'We sent you a code to reset your password.',
  'Recupera tu contraseña': 'Reset your password',
  'Nueva contraseña': 'New password',
  'Crea una contraseña nueva para tu cuenta.':
      'Create a new password for your account.',
  'Repite la contraseña': 'Repeat the password',
  'Las contraseñas no coinciden': "Passwords don't match",
  'Guardar contraseña': 'Save password',
  'Tu contraseña se actualizó correctamente.':
      'Your password was updated successfully.',
  // Calificaciones
  'Mis calificaciones': 'My ratings',
  'No pudimos cargar tus calificaciones': "We couldn't load your ratings",
  'Aún no tienes calificaciones': "You don't have any ratings yet",
  'Cuando completes viajes, las reseñas aparecerán aquí.':
      'When you complete trips, reviews will appear here.',
  '{n} reseñas': '{n} reviews',
  'No pudimos cargar las reseñas': "We couldn't load the reviews",
  'Sin reseñas todavía': 'No reviews yet',
  // Seguimiento del viaje
  'Voy en camino': "I'm on my way",
  'Llegué': "I've arrived",
  'El pasajero fue avisado.': 'The passenger was notified.',
  'A · Recoger': 'A · Pickup',
  'B · Destino': 'B · Destination',
  'Esperando al pasajero · {time}': 'Waiting for the passenger · {time}',
  'Tiempo de espera agotado. Puedes iniciar o cancelar.':
      'Wait time is up. You can start or cancel.',
  'Conductor confirmado': 'Driver confirmed',
  'Tu conductor se está preparando.': 'Your driver is getting ready.',
  'Tu conductor va en camino': 'Your driver is on the way',
  'Está yendo a tu punto de partida.': 'They are heading to your pickup point.',
  '¡Tu conductor llegó!': 'Your driver has arrived!',
  'Te está esperando. Sal en {time} para no perder tu viaje.':
      "They are waiting for you. Head out in {time} so you don't miss your trip.",
  'Te está esperando en el punto de partida.':
      'They are waiting for you at the pickup point.',
  'Vas en camino a tu destino.': 'You are on your way to your destination.',
  // Fotos (avatar / auto)
  'Tomar foto': 'Take photo',
  'Elegir de la galería': 'Choose from gallery',
  'Subir fotos requiere una cuenta real.':
      'Uploading photos requires a real account.',
  'No se pudo subir la imagen.': "Couldn't upload the image.",
  'Máximo 6 fotos del auto.': 'Maximum 6 car photos.',
  'Fotos del auto': 'Car photos',
  'Ayuda al pasajero a reconocer tu auto.':
      'Help the passenger recognize your car.',
  // Métodos de pago
  'Método de pago': 'Payment method',
  'Métodos de pago': 'Payment methods',
  'Efectivo': 'Cash',
  'El conductor verá cómo prefieres pagar el viaje.':
      'The driver will see how you prefer to pay for the trip.',
};

const Map<String, String> commonPt = {
  // Acciones / botones
  'Cancelar': 'Cancelar',
  'Confirmar': 'Confirmar',
  'Aceptar': 'Aceitar',
  'Guardar': 'Salvar',
  'Guardar cambios': 'Salvar alterações',
  'Continuar': 'Continuar',
  'Reintentar': 'Tentar de novo',
  'Cerrar': 'Fechar',
  'Cerrar sesión': 'Sair',
  'Sí': 'Sim',
  'No': 'Não',
  'Listo': 'Pronto',
  'Aceptar tarifa': 'Aceitar tarifa',
  'Guardando…': 'Salvando…',
  'Cargando…': 'Carregando…',
  // Ciudad / ubicación
  'Ciudad': 'Cidade',
  'Selecciona tu ciudad': 'Selecione sua cidade',
  'Buscar ciudad o región…': 'Buscar cidade ou região…',
  'Busca una dirección, calle o lugar…': 'Busque um endereço, rua ou lugar…',
  'Confirmar ubicación': 'Confirmar localização',
  'Confirmar origen': 'Confirmar origem',
  'Confirmar destino': 'Confirmar destino',
  'Buscando dirección…': 'Buscando endereço…',
  'Mueve el mapa para elegir': 'Mova o mapa para escolher',
  'Ubicación seleccionada': 'Localização selecionada',
  'Mi ubicación actual': 'Minha localização atual',
  'No pudimos obtener tu ubicación. Revisa los permisos.':
      'Não foi possível obter sua localização. Verifique as permissões.',
  'Ruta del viaje': 'Rota da viagem',
  // Calificación
  'Enviar calificación': 'Enviar avaliação',
  'Escribe un comentario (opcional)': 'Escreva um comentário (opcional)',
  '¡Gracias por tu calificación!': 'Obrigado pela sua avaliação!',
  'No se pudo guardar la calificación': 'Não foi possível salvar a avaliação',
  'Califica a tu {role}': 'Avalie seu {role}',
  // Apariencia / roles
  'Modo claro': 'Modo claro',
  'Modo oscuro': 'Modo escuro',
  'conductor': 'motorista',
  'pasajero': 'passageiro',
  'Conductor': 'Motorista',
  'Pasajero': 'Passageiro',
  // Idioma
  'Idioma': 'Idioma',
  'Automático (dispositivo)': 'Automático (dispositivo)',
  'Selecciona un idioma': 'Selecione um idioma',
  // Navegación
  'Navegar': 'Navegar',
  'Abrir con': 'Abrir com',
  'Ver la ruta en el mapa': 'Ver a rota no mapa',
  'Navegación paso a paso': 'Navegação passo a passo',
  'No se pudo abrir Waze': 'Não foi possível abrir o Waze',
  // Notificaciones
  'Nueva solicitud de viaje': 'Nova solicitação de viagem',
  'Nueva oferta recibida': 'Nova oferta recebida',
  '¡Tu oferta fue aceptada!': 'Sua oferta foi aceita!',
  'El pasajero te eligió. ¡Prepárate para el viaje!':
      'O passageiro escolheu você. Prepare-se para a viagem!',
  // Estados de viaje / rol
  'Buscando conductor': 'Procurando motorista',
  'Conductor asignado': 'Motorista designado',
  'En viaje': 'Em viagem',
  'Completado': 'Concluído',
  'Cancelado': 'Cancelado',
  'Administrador': 'Administrador',
  // Validaciones de formulario
  'Este campo': 'Este campo',
  '{field} es obligatorio': '{field} é obrigatório',
  'Año no válido': 'Ano inválido',
  'Correo no válido': 'E-mail inválido',
  'Ingresa el año': 'Digite o ano',
  'Ingresa la patente': 'Digite a placa',
  'Ingresa tu correo': 'Digite seu e-mail',
  'Ingresa tu nombre': 'Digite seu nome',
  'Ingresa tu teléfono': 'Digite seu telefone',
  'Ingresa una contraseña': 'Digite uma senha',
  'Mínimo 6 caracteres': 'Mínimo de 6 caracteres',
  'Nombre demasiado corto': 'Nome muito curto',
  'Patente no válida (ej: BBBB12)': 'Placa inválida (ex: BBBB12)',
  'Teléfono no válido': 'Telefone inválido',
  // Tiempo relativo
  'recién': 'agora',
  'ayer': 'ontem',
  'hace {n} min': 'há {n} min',
  'hace {n} h': 'há {n} h',
  'hace {n} días': 'há {n} dias',
  // Recuperación de contraseña
  '¿Olvidaste tu contraseña?': 'Esqueceu sua senha?',
  'Recuperar contraseña': 'Recuperar senha',
  'Te enviaremos un enlace a tu correo para restablecer tu contraseña.':
      'Enviaremos um link ao seu e-mail para redefinir sua senha.',
  'Enviar': 'Enviar',
  'Te enviamos un correo para recuperar tu contraseña.':
      'Enviamos um e-mail para recuperar sua senha.',
  'No se pudo enviar el correo de recuperación.':
      'Não foi possível enviar o e-mail de recuperação.',
  'Te enviamos un código para recuperar tu contraseña.':
      'Enviamos um código para recuperar sua senha.',
  'Recupera tu contraseña': 'Recupere sua senha',
  'Nueva contraseña': 'Nova senha',
  'Crea una contraseña nueva para tu cuenta.':
      'Crie uma nova senha para sua conta.',
  'Repite la contraseña': 'Repita a senha',
  'Las contraseñas no coinciden': 'As senhas não coincidem',
  'Guardar contraseña': 'Salvar senha',
  'Tu contraseña se actualizó correctamente.':
      'Sua senha foi atualizada com sucesso.',
  // Calificaciones
  'Mis calificaciones': 'Minhas avaliações',
  'No pudimos cargar tus calificaciones':
      'Não foi possível carregar suas avaliações',
  'Aún no tienes calificaciones': 'Você ainda não tem avaliações',
  'Cuando completes viajes, las reseñas aparecerán aquí.':
      'Quando você concluir viagens, as avaliações aparecerão aqui.',
  '{n} reseñas': '{n} avaliações',
  'No pudimos cargar las reseñas': 'Não foi possível carregar as avaliações',
  'Sin reseñas todavía': 'Sem avaliações ainda',
  // Seguimiento del viaje
  'Voy en camino': 'Estou a caminho',
  'Llegué': 'Cheguei',
  'El pasajero fue avisado.': 'O passageiro foi avisado.',
  'A · Recoger': 'A · Buscar',
  'B · Destino': 'B · Destino',
  'Esperando al pasajero · {time}': 'Aguardando o passageiro · {time}',
  'Tiempo de espera agotado. Puedes iniciar o cancelar.':
      'Tempo de espera esgotado. Você pode iniciar ou cancelar.',
  'Conductor confirmado': 'Motorista confirmado',
  'Tu conductor se está preparando.': 'Seu motorista está se preparando.',
  'Tu conductor va en camino': 'Seu motorista está a caminho',
  'Está yendo a tu punto de partida.': 'Ele está indo ao seu ponto de partida.',
  '¡Tu conductor llegó!': 'Seu motorista chegou!',
  'Te está esperando. Sal en {time} para no perder tu viaje.':
      'Ele está esperando por você. Saia em {time} para não perder sua viagem.',
  'Te está esperando en el punto de partida.':
      'Ele está esperando por você no ponto de partida.',
  'Vas en camino a tu destino.': 'Você está a caminho do seu destino.',
  // Fotos (avatar / auto)
  'Tomar foto': 'Tirar foto',
  'Elegir de la galería': 'Escolher da galeria',
  'Subir fotos requiere una cuenta real.':
      'Enviar fotos requer uma conta real.',
  'No se pudo subir la imagen.': 'Não foi possível enviar a imagem.',
  'Máximo 6 fotos del auto.': 'Máximo de 6 fotos do carro.',
  'Fotos del auto': 'Fotos do carro',
  'Ayuda al pasajero a reconocer tu auto.':
      'Ajude o passageiro a reconhecer seu carro.',
  // Métodos de pago
  'Método de pago': 'Forma de pagamento',
  'Métodos de pago': 'Formas de pagamento',
  'Efectivo': 'Dinheiro',
  'El conductor verá cómo prefieres pagar el viaje.':
      'O motorista verá como você prefere pagar a viagem.',
};
