# Wheater_App

La aplicación hecha con Flutter, muestra el clima actual de El Salvador y un pronóstico de las próximas horas utilizando la API de OpenWeatherMap para obtener los datos climáticos.
Requisitos
• [Flutter](https://flutter.dev/docs/get-started/install) 3.0 o superior.
• Una clave API de [OpenWeatherMap](https://openweathermap.org/api).
Instalación

1. Descargar el proyecto
   Descargar o clonar el Proyecto Weather_app en la computadora con el link:
   [LINK](https://github.com/Val435/Parcial_app.git)
2. Abrir el proyecto
   Abrir el proyecto de preferencia en Visual Studio Code.
3. Instalar las dependencias:
   Dentro del proyecto ejecutar el comando:
   flutter pub get
4. Configurar la clave API:
   En el archivo lib/secrets.dart se encuentra la API:
   const String openWeatherAPIKey = 'TU_CLAVE_API';
   Reemplaza 'TU_CLAVE_API' con la clave API de OpenWeatherMap.que se encuentra en el archivo api.txt

Ejecución

1. Iniciar un emulador:
   Iniciar un emulador de Android Studio.
2. Ejecuta la aplicación:
   • En el directorio del proyecto en la terminal, ejecuta: flutter run
   • En Visual Studio en Run -> Start Debbuging
   • En el Main.dart en Run
   La aplicación se iniciará y mostrará la información del clima para El Salvador.
   Descripción de la API y Conexión

API Utilizada
La aplicación utiliza la API de OpenWeatherMap para obtener los datos climáticos en tiempo real. La API proporciona información detallada sobre las condiciones meteorológicas actuales y pronósticos para las próximas horas.

Conexión a la API
La aplicación se conecta a la API de OpenWeatherMap mediante una solicitud HTTP GET, utilizando una URL que incluye el nombre de la ciudad y la clave API:
final res = await http.get(Uri.parse(
'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$openWeatherAPIKey',
));
Los datos se reciben en formato JSON y se procesan para extraer la información relevante, como la temperatura actual, las condiciones climáticas, y otros datos como la humedad, la velocidad del viento y la presión. Se manejan los posibles errores de conexión o de respuesta de la API, y se muestran mensajes de error amigables al usuario en caso de que ocurra un problema.

Visualización de Datos en Tiempo Real
La aplicación obtiene datos actualizados del clima cada minuto gracias a un Timer que ejecuta periódicamente la función getCurrentWeather(). Los datos obtenidos incluyen:
• Temperatura actual: Se muestra en grados Celsius.
• Condición climática: Despejado, nublado, lluvia, etc.
• Pronóstico con intervalo de tres horas: Se muestra en un ListView horizontal con los próximos pronósticos.
• Información adicional: Se presenta la humedad, la velocidad del viento y la presión atmosférica.
La visualización se realiza mediante un FutureBuilder, que actualiza la interfaz en tiempo real a medida que se reciben nuevos datos. Esto asegura que el usuario siempre vea la información más reciente disponible por la API.

Personalización
• Cambiar la ciudad: Puedes modificar la variable a nivel de código en cityName en WeatherScreen para obtener el clima de otra ciudad,
• Intervalo de actualización: El intervalo de actualización se puede ajustar modificando la duración en Timer.periodic pero por el momento tiene un minuto.

Este `README.md` proporciona toda la información necesaria para que otro desarrollador pueda ejecutar la aplicación sin problemas. También ofrece una descripción clara y detallada de cómo la aplicación se conecta a la API de OpenWeatherMap y cómo se manejan y muestran los datos en tiempo real.
