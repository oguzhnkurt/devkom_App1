# Devi'nin bilmeceleri — ARDUINO (14), TINKERCAD (10), DONANIM (12)
ARDUINO = [
 (0, {
  'tr': ("Arduino kodunda yalnızca bir kez, en başta çalışan bölüm hangisi?", ["setup()", "loop()", "delay()"], "setup() kart açılınca bir kez çalışır; ayarlar burada yapılır."),
  'en': ("Which part of Arduino code runs only once, at the start?", ["setup()", "loop()", "delay()"], "setup() runs once when the board starts; settings go here."),
  'de': ("Welcher Teil im Arduino-Code läuft nur einmal am Anfang?", ["setup()", "loop()", "delay()"], "setup() läuft einmal beim Start; dort stehen die Einstellungen."),
  'es': ("¿Qué parte del código de Arduino se ejecuta solo una vez al inicio?", ["setup()", "loop()", "delay()"], "setup() se ejecuta una vez al encender; ahí van los ajustes."),
 }),
 (1, {
  'tr': ("Arduino'da sürekli tekrar eden bölüm hangisi?", ["setup()", "loop()", "pinMode()"], "loop() kart açık kaldıkça tekrar tekrar çalışır."),
  'en': ("Which part of Arduino code repeats over and over?", ["setup()", "loop()", "pinMode()"], "loop() runs again and again while the board is on."),
  'de': ("Welcher Teil im Arduino-Code wiederholt sich immer wieder?", ["setup()", "loop()", "pinMode()"], "loop() läuft immer wieder, solange das Board an ist."),
  'es': ("¿Qué parte del código de Arduino se repite una y otra vez?", ["setup()", "loop()", "pinMode()"], "loop() se ejecuta una y otra vez mientras la placa está encendida."),
 }),
 (2, {
  'tr': ("13 numaralı pine bağlı LED'i yakan komut hangisi?", ["digitalRead(13)", "pinMode(13, INPUT)", "digitalWrite(13, HIGH)"], "digitalWrite pine elektrik verir; HIGH “açık” demektir."),
  'en': ("Which command lights the LED on pin 13?", ["digitalRead(13)", "pinMode(13, INPUT)", "digitalWrite(13, HIGH)"], "digitalWrite powers the pin; HIGH means on."),
  'de': ("Welcher Befehl schaltet die LED an Pin 13 ein?", ["digitalRead(13)", "pinMode(13, INPUT)", "digitalWrite(13, HIGH)"], "digitalWrite schaltet den Pin; HIGH heißt an."),
  'es': ("¿Qué instrucción enciende el LED del pin 13?", ["digitalRead(13)", "pinMode(13, INPUT)", "digitalWrite(13, HIGH)"], "digitalWrite da corriente al pin; HIGH significa encendido."),
 }),
 (0, {
  'tr': ("Bir pini çıkış yapmak için ne yazılır?", ["pinMode(13, OUTPUT)", "digitalRead(13)", "delay(13)"], "pinMode pinin giriş mi çıkış mı olacağını söyler."),
  'en': ("What do you write to make a pin an output?", ["pinMode(13, OUTPUT)", "digitalRead(13)", "delay(13)"], "pinMode says whether a pin is an input or an output."),
  'de': ("Was schreibst du, damit ein Pin ein Ausgang wird?", ["pinMode(13, OUTPUT)", "digitalRead(13)", "delay(13)"], "pinMode legt fest, ob ein Pin Eingang oder Ausgang ist."),
  'es': ("¿Qué escribes para que un pin sea una salida?", ["pinMode(13, OUTPUT)", "digitalRead(13)", "delay(13)"], "pinMode indica si un pin es entrada o salida."),
 }),
 (1, {
  'tr': ("delay(1000) programı ne kadar bekletir?", ["1000 saniye", "1 saniye", "10 saniye"], "delay milisaniye ile çalışır: 1000 ms = 1 saniye."),
  'en': ("How long does delay(1000) wait?", ["1000 seconds", "1 second", "10 seconds"], "delay uses milliseconds: 1000 ms = 1 second."),
  'de': ("Wie lange wartet delay(1000)?", ["1000 Sekunden", "1 Sekunde", "10 Sekunden"], "delay rechnet in Millisekunden: 1000 ms = 1 Sekunde."),
  'es': ("¿Cuánto espera delay(1000)?", ["1000 segundos", "1 segundo", "10 segundos"], "delay usa milisegundos: 1000 ms = 1 segundo."),
 }),
 (2, {
  'tr': ("Arduino Uno'da kaç analog giriş pini vardır?", ["2", "14", "6 (A0 - A5)"], "Uno'da A0'dan A5'e kadar 6 analog giriş vardır."),
  'en': ("How many analog input pins does an Arduino Uno have?", ["2", "14", "6 (A0 - A5)"], "The Uno has 6 analog inputs, A0 to A5."),
  'de': ("Wie viele analoge Eingänge hat ein Arduino Uno?", ["2", "14", "6 (A0 - A5)"], "Der Uno hat 6 analoge Eingänge, A0 bis A5."),
  'es': ("¿Cuántos pines de entrada analógica tiene un Arduino Uno?", ["2", "14", "6 (A0 - A5)"], "El Uno tiene 6 entradas analógicas, de A0 a A5."),
 }),
 (0, {
  'tr': ("Arduino Uno'da kaç dijital pin vardır?", ["14 (0 - 13)", "6", "100"], "Uno'nun 0'dan 13'e kadar 14 dijital pini vardır."),
  'en': ("How many digital pins does an Arduino Uno have?", ["14 (0 - 13)", "6", "100"], "The Uno has 14 digital pins, numbered 0 to 13."),
  'de': ("Wie viele digitale Pins hat ein Arduino Uno?", ["14 (0 - 13)", "6", "100"], "Der Uno hat 14 digitale Pins, von 0 bis 13."),
  'es': ("¿Cuántos pines digitales tiene un Arduino Uno?", ["14 (0 - 13)", "6", "100"], "El Uno tiene 14 pines digitales, del 0 al 13."),
 }),
 (1, {
  'tr': ("Arduino Uno'nun “beyni” olan çipin adı nedir?", ["Pentium", "ATmega328P", "Bluetooth"], "ATmega328P bir mikrodenetleyicidir: kodu çalıştıran küçük bilgisayar."),
  'en': ("What is the chip that is the “brain” of an Arduino Uno?", ["Pentium", "ATmega328P", "Bluetooth"], "The ATmega328P is a microcontroller: a tiny computer that runs the code."),
  'de': ("Wie heißt der Chip, der das „Gehirn“ des Arduino Uno ist?", ["Pentium", "ATmega328P", "Bluetooth"], "Der ATmega328P ist ein Mikrocontroller: ein winziger Computer für den Code."),
  'es': ("¿Cómo se llama el chip que es el “cerebro” del Arduino Uno?", ["Pentium", "ATmega328P", "Bluetooth"], "El ATmega328P es un microcontrolador: un ordenador diminuto que ejecuta el código."),
 }),
 (0, {
  'tr': ("LED'in uzun bacağı hangi uçtur?", ["Artı (+)", "Eksi (-)", "İkisi de aynı"], "Uzun bacak artıdır (anot); kısa bacak eksiye (GND) gider."),
  'en': ("Which end is an LED's longer leg?", ["Plus (+)", "Minus (-)", "Both are the same"], "The long leg is plus (anode); the short leg goes to minus (GND)."),
  'de': ("Welches Ende ist das längere Bein einer LED?", ["Plus (+)", "Minus (-)", "Beide sind gleich"], "Das lange Bein ist Plus (Anode); das kurze geht an Minus (GND)."),
  'es': ("¿Qué extremo es la pata más larga de un LED?", ["Positivo (+)", "Negativo (-)", "Son iguales"], "La pata larga es el positivo (ánodo); la corta va al negativo (GND)."),
 }),
 (2, {
  'tr': ("LED'e neden seri bir direnç takarız?", ["Daha çok ses çıksın diye", "Rengi değişsin diye", "Akımı sınırlayıp LED'i korumak için"], "Direnç olmadan çok akım geçer ve LED bozulabilir."),
  'en': ("Why do we put a resistor in series with an LED?", ["To make more sound", "To change its colour", "To limit the current and protect the LED"], "Without a resistor too much current flows and the LED can break."),
  'de': ("Warum setzt man einen Widerstand vor eine LED?", ["Damit es lauter wird", "Damit sich die Farbe ändert", "Um den Strom zu begrenzen und die LED zu schützen"], "Ohne Widerstand fließt zu viel Strom und die LED kann kaputtgehen."),
  'es': ("¿Por qué ponemos una resistencia en serie con un LED?", ["Para que suene más", "Para cambiar su color", "Para limitar la corriente y proteger el LED"], "Sin resistencia pasa demasiada corriente y el LED puede romperse."),
 }),
 (1, {
  'tr': ("Arduino kodunda her komutun sonuna ne konur?", ["Nokta (.)", "Noktalı virgül (;)", "Soru işareti (?)"], "C dilinde her komut noktalı virgülle biter; unutulursa kod derlenmez."),
  'en': ("What goes at the end of each command in Arduino code?", ["A full stop (.)", "A semicolon (;)", "A question mark (?)"], "In C every statement ends with a semicolon; forget it and the code won't compile."),
  'de': ("Was steht im Arduino-Code am Ende jedes Befehls?", ["Ein Punkt (.)", "Ein Semikolon (;)", "Ein Fragezeichen (?)"], "In C endet jede Anweisung mit Semikolon; fehlt es, kompiliert der Code nicht."),
  'es': ("¿Qué va al final de cada instrucción en el código de Arduino?", ["Un punto (.)", "Un punto y coma (;)", "Un signo de interrogación (?)"], "En C cada instrucción termina en punto y coma; si falta, no compila."),
 }),
 (0, {
  'tr': ("Seri monitöre “Merhaba” yazdırmak için hangisi kullanılır?", ["Serial.println(\"Merhaba\")", "digitalWrite(\"Merhaba\")", "delay(\"Merhaba\")"], "Serial.println yazıyı bilgisayardaki seri monitöre gönderir."),
  'en': ("Which line prints “Hello” to the Serial Monitor?", ["Serial.println(\"Hello\")", "digitalWrite(\"Hello\")", "delay(\"Hello\")"], "Serial.println sends the text to the Serial Monitor on the computer."),
  'de': ("Welche Zeile schreibt „Hallo“ in den seriellen Monitor?", ["Serial.println(\"Hallo\")", "digitalWrite(\"Hallo\")", "delay(\"Hallo\")"], "Serial.println schickt den Text an den seriellen Monitor."),
  'es': ("¿Qué línea escribe “Hola” en el monitor serie?", ["Serial.println(\"Hola\")", "digitalWrite(\"Hola\")", "delay(\"Hola\")"], "Serial.println envía el texto al monitor serie del ordenador."),
 }),
 (2, {
  'tr': ("Potansiyometre nedir?", ["Bir hoparlör", "Bir LED türü", "Çevirince değeri değişen ayarlı direnç"], "Düğmeyi çevirdikçe analog okunan değer 0 ile 1023 arasında değişir."),
  'en': ("What is a potentiometer?", ["A speaker", "A type of LED", "A knob that changes resistance as you turn it"], "As you turn it, the analog reading changes between 0 and 1023."),
  'de': ("Was ist ein Potentiometer?", ["Ein Lautsprecher", "Eine LED-Art", "Ein Drehregler, dessen Widerstand sich ändert"], "Beim Drehen ändert sich der Analogwert zwischen 0 und 1023."),
  'es': ("¿Qué es un potenciómetro?", ["Un altavoz", "Un tipo de LED", "Una perilla que cambia su resistencia al girarla"], "Al girarla, la lectura analógica cambia entre 0 y 1023."),
 }),
 (1, {
  'tr': ("Arduino Uno üzerindeki küçük dahili LED hangi pine bağlıdır?", ["Pin 2", "Pin 13", "Pin A0"], "Bu yüzden ilk “Blink” örneği 13. pini kullanır."),
  'en': ("Which pin is the Uno's small built-in LED connected to?", ["Pin 2", "Pin 13", "Pin A0"], "That's why the first “Blink” example uses pin 13."),
  'de': ("An welchem Pin hängt die kleine eingebaute LED des Uno?", ["Pin 2", "Pin 13", "Pin A0"], "Darum nutzt das erste „Blink“-Beispiel Pin 13."),
  'es': ("¿A qué pin está conectado el pequeño LED integrado del Uno?", ["Pin 2", "Pin 13", "Pin A0"], "Por eso el primer ejemplo “Blink” usa el pin 13."),
 }),
]

TINKERCAD = [
 (1, {
  'tr': ("Tinkercad nedir?", ["Bir oyun konsolu", "Tarayıcıda çalışan ücretsiz 3B tasarım ve devre uygulaması", "Bir yazıcı markası"], "Tinkercad'i Autodesk sunar; kurulum gerekmez."),
  'en': ("What is Tinkercad?", ["A game console", "A free browser app for 3D design and circuits", "A printer brand"], "Tinkercad is made by Autodesk and needs no installation."),
  'de': ("Was ist Tinkercad?", ["Eine Spielkonsole", "Eine kostenlose Browser-App für 3D-Design und Schaltungen", "Eine Druckermarke"], "Tinkercad kommt von Autodesk und braucht keine Installation."),
  'es': ("¿Qué es Tinkercad?", ["Una consola de juegos", "Una app gratuita en el navegador para diseño 3D y circuitos", "Una marca de impresoras"], "Tinkercad es de Autodesk y no necesita instalación."),
 }),
 (0, {
  'tr': ("Tinkercad Circuits ne işe yarar?", ["Devreleri sanal kurup çalıştırmayı", "Video düzenlemeyi", "Müzik yapmayı"], "Gerçek parça almadan Arduino devresi kurup deneyebilirsin."),
  'en': ("What is Tinkercad Circuits for?", ["Building and running circuits virtually", "Editing videos", "Making music"], "You can build and test an Arduino circuit without buying parts."),
  'de': ("Wofür ist Tinkercad Circuits?", ["Schaltungen virtuell bauen und starten", "Videos schneiden", "Musik machen"], "Du kannst Arduino-Schaltungen ohne echte Bauteile bauen und testen."),
  'es': ("¿Para qué sirve Tinkercad Circuits?", ["Montar y probar circuitos virtuales", "Editar vídeos", "Hacer música"], "Puedes montar y probar un circuito Arduino sin comprar piezas."),
 }),
 (2, {
  'tr': ("Tinkercad'de devrenin çalışıp çalışmadığını görmek için hangi düğmeye basarsın?", ["Dışa aktar", "Paylaş", "Simülasyonu Başlat"], "Simülasyon, devreyi gerçekmiş gibi çalıştırır."),
  'en': ("In Tinkercad, which button shows whether your circuit works?", ["Export", "Share", "Start Simulation"], "The simulation runs the circuit as if it were real."),
  'de': ("Welcher Knopf zeigt in Tinkercad, ob die Schaltung funktioniert?", ["Exportieren", "Teilen", "Simulation starten"], "Die Simulation lässt die Schaltung wie echt laufen."),
  'es': ("En Tinkercad, ¿qué botón muestra si tu circuito funciona?", ["Exportar", "Compartir", "Iniciar simulación"], "La simulación hace funcionar el circuito como si fuera real."),
 }),
 (1, {
  'tr': ("Breadboard (devre tahtası) ne işe yarar?", ["Kodu saklar", "Lehim yapmadan devre kurmayı sağlar", "Pili şarj eder"], "Parçaları deliklere takıp çıkararak kolayca devre kurarsın."),
  'en': ("What is a breadboard for?", ["Storing code", "Building circuits without soldering", "Charging batteries"], "You plug parts into the holes and can easily change the circuit."),
  'de': ("Wofür ist ein Steckbrett (Breadboard)?", ["Code speichern", "Schaltungen ohne Löten bauen", "Akkus laden"], "Bauteile werden eingesteckt und lassen sich leicht umstecken."),
  'es': ("¿Para qué sirve una protoboard?", ["Guardar código", "Montar circuitos sin soldar", "Cargar pilas"], "Pinchas las piezas en los agujeros y cambias el circuito fácilmente."),
 }),
 (0, {
  'tr': ("Breadboard'un kenarındaki kırmızı (+) ve mavi (-) uzun çizgiler nedir?", ["Güç hatları", "Süs çizgileri", "Ses kabloları"], "Kenardaki uzun hatlar artı ve eksiyi tahtanın her yerine taşır."),
  'en': ("What are the long red (+) and blue (-) lines along a breadboard's edge?", ["Power rails", "Decoration", "Sound wires"], "The long rails carry plus and minus all along the board."),
  'de': ("Was sind die langen roten (+) und blauen (-) Linien am Rand des Steckbretts?", ["Stromschienen", "Verzierung", "Tonkabel"], "Die Schienen führen Plus und Minus über das ganze Brett."),
  'es': ("¿Qué son las líneas largas roja (+) y azul (-) del borde de la protoboard?", ["Líneas de alimentación", "Adornos", "Cables de sonido"], "Llevan el positivo y el negativo a lo largo de toda la placa."),
 }),
 (2, {
  'tr': ("Tinkercad'de iki 3B şekli tek parça yapmak için ne kullanırsın?", ["Sil", "Kopyala", "Grupla"], "Grupla, seçili şekilleri tek bir nesne yapar."),
  'en': ("In Tinkercad, what joins two 3D shapes into one piece?", ["Delete", "Copy", "Group"], "Group turns the selected shapes into one object."),
  'de': ("Womit machst du in Tinkercad aus zwei 3D-Formen ein Teil?", ["Löschen", "Kopieren", "Gruppieren"], "Gruppieren macht aus den gewählten Formen ein Objekt."),
  'es': ("En Tinkercad, ¿qué une dos formas 3D en una sola pieza?", ["Eliminar", "Copiar", "Agrupar"], "Agrupar convierte las formas elegidas en un solo objeto."),
 }),
 (1, {
  'tr': ("Tinkercad'de bir kutunun içini oymak için şekli ne yaparsın?", ["Kırmızı renk", "Delik", "Daha büyük"], "Delik yapılan şekil, gruplayınca diğerinden çıkarılır."),
  'en': ("In Tinkercad, how do you carve a space into a box?", ["Make the shape red", "Make the shape a Hole", "Make it bigger"], "A Hole shape is cut out of the other shape when you group them."),
  'de': ("Wie höhlst du in Tinkercad eine Kiste aus?", ["Form rot färben", "Form zur Bohrung machen", "Form vergrößern"], "Eine Bohrung wird beim Gruppieren aus der anderen Form herausgeschnitten."),
  'es': ("En Tinkercad, ¿cómo vacías una caja?", ["Pintar la forma de rojo", "Convertir la forma en Agujero", "Hacerla más grande"], "Una forma Agujero se resta de la otra al agruparlas."),
 }),
 (0, {
  'tr': ("Tinkercad'de Arduino'yu kodlamanın kolay yolu hangisi?", ["Bloklar modu", "Excel tablosu", "Ses kaydı"], "Kod düzenleyicisinde Bloklar, Bloklar + Metin ve Metin modları vardır."),
  'en': ("What is the easy way to code an Arduino in Tinkercad?", ["Blocks mode", "A spreadsheet", "A voice recording"], "The code editor has Blocks, Blocks + Text and Text modes."),
  'de': ("Wie programmierst du einen Arduino in Tinkercad am einfachsten?", ["Blöcke-Modus", "Eine Tabelle", "Eine Sprachaufnahme"], "Der Code-Editor hat die Modi Blöcke, Blöcke + Text und Text."),
  'es': ("¿Cuál es la forma fácil de programar un Arduino en Tinkercad?", ["Modo Bloques", "Una hoja de cálculo", "Una grabación de voz"], "El editor tiene los modos Bloques, Bloques + Texto y Texto."),
 }),
 (2, {
  'tr': ("Tinkercad'deki 3B tasarımı 3B yazıcıya göndermek için en yaygın dosya türü?", ["MP3", "JPG", "STL"], "3B yazıcılar çoğunlukla STL dosyalarını okur."),
  'en': ("Which file type is most common for sending a Tinkercad design to a 3D printer?", ["MP3", "JPG", "STL"], "3D printers usually read STL files."),
  'de': ("Welcher Dateityp ist für den 3D-Druck aus Tinkercad am üblichsten?", ["MP3", "JPG", "STL"], "3D-Drucker lesen meist STL-Dateien."),
  'es': ("¿Qué tipo de archivo se usa más para imprimir en 3D un diseño de Tinkercad?", ["MP3", "JPG", "STL"], "Las impresoras 3D suelen leer archivos STL."),
 }),
 (1, {
  'tr': ("Tinkercad devresinde multimetre ile neyi ölçersin?", ["Sıcaklığı", "Voltaj, akım ya da direnci", "Hızı"], "Multimetre elektrik değerlerini ölçen araçtır."),
  'en': ("What do you measure with a multimeter in a Tinkercad circuit?", ["Temperature", "Voltage, current or resistance", "Speed"], "A multimeter measures electrical values."),
  'de': ("Was misst du in Tinkercad mit einem Multimeter?", ["Temperatur", "Spannung, Strom oder Widerstand", "Geschwindigkeit"], "Ein Multimeter misst elektrische Werte."),
  'es': ("¿Qué mides con un multímetro en un circuito de Tinkercad?", ["Temperatura", "Voltaje, corriente o resistencia", "Velocidad"], "Un multímetro mide valores eléctricos."),
 }),
]

DONANIM = [
 (0, {
  'tr': ("Bilgisayarın “beyni” olan, hesapları yapan iç donanım hangisi?", ["İşlemci (CPU)", "Klavye", "Hoparlör"], "İşlemci komutları çalıştırır; kasanın içindedir."),
  'en': ("Which internal part is the computer's “brain” and does the calculations?", ["Processor (CPU)", "Keyboard", "Speaker"], "The processor runs instructions; it is inside the case."),
  'de': ("Welches innere Bauteil ist das „Gehirn“ des Computers und rechnet?", ["Prozessor (CPU)", "Tastatur", "Lautsprecher"], "Der Prozessor führt Befehle aus; er sitzt im Gehäuse."),
  'es': ("¿Qué pieza interna es el “cerebro” del ordenador y hace los cálculos?", ["Procesador (CPU)", "Teclado", "Altavoz"], "El procesador ejecuta instrucciones; está dentro de la caja."),
 }),
 (1, {
  'tr': ("Bilgisayar kapanınca içindekiler silinen geçici bellek hangisi?", ["SSD", "RAM", "Monitör"], "RAM hızlıdır ama geçicidir; elektrik gidince boşalır."),
  'en': ("Which temporary memory loses its contents when the computer turns off?", ["SSD", "RAM", "Monitor"], "RAM is fast but temporary; it empties when the power goes."),
  'de': ("Welcher Arbeitsspeicher verliert beim Ausschalten seinen Inhalt?", ["SSD", "RAM", "Monitor"], "RAM ist schnell, aber flüchtig; ohne Strom ist er leer."),
  'es': ("¿Qué memoria temporal se borra al apagar el ordenador?", ["SSD", "RAM", "Monitor"], "La RAM es rápida pero temporal; se vacía al cortar la corriente."),
 }),
 (2, {
  'tr': ("Klavye hangi tür donanımdır?", ["İç donanım", "Çıkış birimi", "Dış donanım, giriş birimi"], "Klavyeyle bilgisayara bilgi girersin; kasanın dışındadır."),
  'en': ("What kind of hardware is a keyboard?", ["Internal hardware", "Output device", "External hardware, input device"], "You put information into the computer with it; it sits outside the case."),
  'de': ("Was für Hardware ist eine Tastatur?", ["Innere Hardware", "Ausgabegerät", "Äußere Hardware, Eingabegerät"], "Mit ihr gibst du Daten ein; sie ist außerhalb des Gehäuses."),
  'es': ("¿Qué tipo de hardware es un teclado?", ["Hardware interno", "Dispositivo de salida", "Hardware externo, de entrada"], "Con él introduces datos; está fuera de la caja."),
 }),
 (0, {
  'tr': ("Monitör hangi birimdir?", ["Çıkış birimi", "Giriş birimi", "Depolama birimi"], "Monitör bilgisayarın ürettiği görüntüyü bize gösterir."),
  'en': ("What kind of device is a monitor?", ["Output device", "Input device", "Storage device"], "A monitor shows us the picture the computer makes."),
  'de': ("Was für ein Gerät ist ein Monitor?", ["Ausgabegerät", "Eingabegerät", "Speichergerät"], "Der Monitor zeigt uns das Bild des Computers."),
  'es': ("¿Qué tipo de dispositivo es un monitor?", ["De salida", "De entrada", "De almacenamiento"], "El monitor nos muestra la imagen que crea el ordenador."),
 }),
 (1, {
  'tr': ("Hangisi bir giriş birimidir?", ["Yazıcı", "Mikrofon", "Hoparlör"], "Mikrofon sesi bilgisayara girer; yazıcı ve hoparlör çıkış verir."),
  'en': ("Which one is an input device?", ["Printer", "Microphone", "Speaker"], "A microphone puts sound in; printers and speakers give output."),
  'de': ("Welches ist ein Eingabegerät?", ["Drucker", "Mikrofon", "Lautsprecher"], "Ein Mikrofon nimmt Ton auf; Drucker und Lautsprecher geben aus."),
  'es': ("¿Cuál es un dispositivo de entrada?", ["Impresora", "Micrófono", "Altavoz"], "El micrófono introduce sonido; impresora y altavoz dan salida."),
 }),
 (2, {
  'tr': ("Bilgisayardaki tüm parçaları birbirine bağlayan büyük kart hangisi?", ["Ekran kartı", "Ses kartı", "Anakart"], "İşlemci, RAM ve diğer parçalar anakarta takılır."),
  'en': ("Which big board connects all the parts of a computer?", ["Graphics card", "Sound card", "Motherboard"], "The CPU, RAM and other parts plug into the motherboard."),
  'de': ("Welche große Platine verbindet alle Teile eines Computers?", ["Grafikkarte", "Soundkarte", "Mainboard"], "CPU, RAM und andere Teile stecken auf dem Mainboard."),
  'es': ("¿Qué placa grande conecta todas las piezas del ordenador?", ["Tarjeta gráfica", "Tarjeta de sonido", "Placa base"], "La CPU, la RAM y otras piezas se conectan a la placa base."),
 }),
 (0, {
  'tr': ("Oyunlardaki görüntüleri hızlıca çizen iç donanım hangisi?", ["Ekran kartı (GPU)", "Fare", "Güç kaynağı"], "Ekran kartı görüntüleri işleyip monitöre gönderir."),
  'en': ("Which internal part quickly draws the images in games?", ["Graphics card (GPU)", "Mouse", "Power supply"], "The graphics card processes images and sends them to the monitor."),
  'de': ("Welches innere Bauteil zeichnet Spielbilder schnell?", ["Grafikkarte (GPU)", "Maus", "Netzteil"], "Die Grafikkarte berechnet Bilder und schickt sie an den Monitor."),
  'es': ("¿Qué pieza interna dibuja rápido las imágenes de los juegos?", ["Tarjeta gráfica (GPU)", "Ratón", "Fuente de alimentación"], "La tarjeta gráfica procesa imágenes y las envía al monitor."),
 }),
 (1, {
  'tr': ("Dosyaların kalıcı olarak saklandığı donanım hangisi?", ["RAM", "SSD ya da sabit disk", "İşlemci"], "SSD ve sabit disk elektrik gidince de bilgiyi saklar."),
  'en': ("Which hardware keeps files permanently?", ["RAM", "SSD or hard disk", "Processor"], "SSDs and hard disks keep data even without power."),
  'de': ("Welche Hardware speichert Dateien dauerhaft?", ["RAM", "SSD oder Festplatte", "Prozessor"], "SSD und Festplatte behalten Daten auch ohne Strom."),
  'es': ("¿Qué hardware guarda los archivos de forma permanente?", ["RAM", "SSD o disco duro", "Procesador"], "El SSD y el disco duro guardan datos incluso sin corriente."),
 }),
 (2, {
  'tr': ("Bilgisayar parçalarına elektrik dağıtan iç donanım hangisi?", ["Anakart", "Monitör", "Güç kaynağı (PSU)"], "Güç kaynağı prizden gelen elektriği parçaların kullanacağı hale getirir."),
  'en': ("Which internal part delivers power to the computer's parts?", ["Motherboard", "Monitor", "Power supply (PSU)"], "The power supply turns mains electricity into what the parts can use."),
  'de': ("Welches innere Bauteil versorgt die Teile mit Strom?", ["Mainboard", "Monitor", "Netzteil (PSU)"], "Das Netzteil wandelt Netzstrom so um, dass die Teile ihn nutzen können."),
  'es': ("¿Qué pieza interna reparte la electricidad a las demás?", ["Placa base", "Monitor", "Fuente de alimentación (PSU)"], "La fuente convierte la electricidad del enchufe para que la usen las piezas."),
 }),
 (0, {
  'tr': ("Fare hangi tür birimdir?", ["Giriş birimi", "Çıkış birimi", "İç donanım"], "Fareyle bilgisayara komut verirsin."),
  'en': ("What kind of device is a mouse?", ["Input device", "Output device", "Internal hardware"], "You give commands to the computer with a mouse."),
  'de': ("Was für ein Gerät ist eine Maus?", ["Eingabegerät", "Ausgabegerät", "Innere Hardware"], "Mit der Maus gibst du dem Computer Befehle."),
  'es': ("¿Qué tipo de dispositivo es un ratón?", ["De entrada", "De salida", "Hardware interno"], "Con el ratón das órdenes al ordenador."),
 }),
 (1, {
  'tr': ("Hangisi bir iç donanımdır?", ["Yazıcı", "RAM", "Kulaklık"], "RAM kasanın içinde anakarta takılır; diğerleri dışarıdan bağlanır."),
  'en': ("Which one is internal hardware?", ["Printer", "RAM", "Headphones"], "RAM plugs into the motherboard inside the case; the others connect outside."),
  'de': ("Was ist innere Hardware?", ["Drucker", "RAM", "Kopfhörer"], "RAM steckt im Gehäuse auf dem Mainboard; die anderen sind außen."),
  'es': ("¿Cuál es hardware interno?", ["Impresora", "RAM", "Auriculares"], "La RAM va en la placa base dentro de la caja; los demás se conectan fuera."),
 }),
 (2, {
  'tr': ("Yazıcı hangi tür birimdir?", ["Giriş birimi", "Depolama birimi", "Çıkış birimi"], "Yazıcı bilgisayardaki bilgiyi kâğıda çıkarır."),
  'en': ("What kind of device is a printer?", ["Input device", "Storage device", "Output device"], "A printer puts the computer's information onto paper."),
  'de': ("Was für ein Gerät ist ein Drucker?", ["Eingabegerät", "Speichergerät", "Ausgabegerät"], "Ein Drucker bringt Daten des Computers auf Papier."),
  'es': ("¿Qué tipo de dispositivo es una impresora?", ["De entrada", "De almacenamiento", "De salida"], "La impresora saca la información del ordenador en papel."),
 }),
]
