# Guía de Configuración de Escenas en Godot - Cyber-Escape (Versión Final Detallada)

Esta guía te explica **paso a paso y con todo detalle** cómo crear y configurar cada escena y nodo en el editor de Godot para que tu juego funcione perfectamente. Presta mucha atención a los **nombres exactos de los nodos** y a los **pasos de "arrastrar y soltar"** en el Inspector.

## 1. Configurar los Singletons (Autoloads)

Estos scripts se cargan automáticamente al inicio del juego y son accesibles desde cualquier parte.

1.  Ve a `Proyecto -> Ajustes del Proyecto...`.
2.  Selecciona la pestaña `Autoload`.
3.  Añade los siguientes dos scripts, asegurándote de usar el **Nombre del Nodo** exacto (es crucial que coincidan):
    - **Ruta:** `res://scripts/singletons/GameManager.gd` -> **Nombre del Nodo:** `GameManager`
    - **Ruta:** `res://scripts/singletons/QuestionManager.gd` -> **Nombre del Nodo:** `QuestionManager`
      (El `DialogueManager` es proporcionado por el plugin y se configura automáticamente.)

## 2. Crear la Escena del Coche del Jugador (`PlayerCar.tscn`)

Esta escena representa el coche que controlas.

1.  **Nueva Escena:** En el editor de Godot, haz clic en `Scene -> New Scene`.
2.  **Nodo Raíz:** Haz clic en `Other Node` y busca `CharacterBody2D`. Haz doble clic para añadirlo. Renómbralo a `PlayerCar`.
3.  **Añadir Componentes:**
    - Añade un nodo `Sprite2D` como hijo de `PlayerCar`. Renómbralo a `Sprite`. Asigna tu textura de coche (ej. `carS1.png`) a la propiedad `Texture` en el Inspector.
    - Añade un nodo `CollisionShape2D` como hijo de `PlayerCar`. Renómbralo a `Collision`. En el `Inspector`, en la propiedad `Shape`, haz clic en `[empty]` y crea un `RectangleShape2D`. Ajusta el tamaño del rectángulo para que cubra tu sprite.
    - Añade un nodo `Timer` como hijo de `PlayerCar`. Renómbralo a `EffectTimer`.
4.  **Adjuntar Script:** Selecciona el nodo `PlayerCar`. En el `Inspector`, en la sección `Script`, haz clic en `[empty]` y selecciona `Load`. Busca y selecciona `res://scripts/player/PlayerCar.gd`.
5.  **Configurar Variables Exportadas:** En el `Inspector`, ajusta las variables:
    - `Base Speed`: Velocidad inicial del coche.
    - `Boost Speed Factor`: Multiplicador de velocidad al acertar.
    - `Stall Speed Factor`: Multiplicador de velocidad al fallar.
    - `Effect Duration`: Duración de los efectos de boost/stall.
    - `Distance Gain On Correct`: Cuánto se aleja del policía al acertar.
6.  **Guardar Escena:** Ve a `Scene -> Save Scene As...`. Guarda la escena como `PlayerCar.tscn` en `res://scenes/player/`.

## 3. Crear la Escena de la Patrulla Policial (`PoliceCar.tscn`)

Esta escena representa a los enemigos que te persiguen.

1.  **Nueva Escena:** Crea una nueva escena (`Scene -> New Scene`).
2.  **Nodo Raíz:** Añade un nodo `CharacterBody2D`. Renómbralo a `PoliceCar`.
3.  **Añadir Componentes:**
    - Añade un nodo `Sprite2D` como hijo de `PoliceCar`. Renómbralo a `Sprite`. Asigna tu textura de policía (ej. `policiaS.png`).
    - Añade un nodo `CollisionShape2D` como hijo de `PoliceCar`. Renómbralo a `Collision`. En el `Inspector`, en la propiedad `Shape`, crea un `RectangleShape2D` y ajústalo al tamaño de tu sprite.
4.  **Adjuntar Script:** Selecciona el nodo `PoliceCar`. Carga el script `res://scripts/enemies/PoliceCar.gd`.
5.  **Configurar Variables Exportadas:** En el `Inspector`, ajusta las variables:
    - `Follow Distance`: Distancia que la policía intenta mantener.
    - `Catch Up Speed Factor`: Qué tan rápido acelera para alcanzar al jugador.
    - `Lunge Speed Boost`: Velocidad extra durante la embestida.
    - `Lunge Duration`: Duración de la embestida.
6.  **Guardar Escena:** Guarda la escena como `PoliceCar.tscn` en `res://scenes/enemies/`.

## 4. Crear la Escena del HUD del Juego (`InGameHUD.tscn`)

Esta escena contiene la interfaz de usuario que se ve _durante_ la partida (barra de tiempo, advertencias, distancia, preguntas).

1.  **Nueva Escena:** Crea una nueva escena (`Scene -> New Scene`).
2.  **Nodo Raíz:** Añade un nodo `CanvasLayer`. Renómbralo a `InGameHUD`.
3.  **Adjuntar Script:** Selecciona el nodo `InGameHUD`. Carga el script `res://scripts/ui/HUD.gd`.
4.  **Construir la Interfaz (dentro de `InGameHUD`):**
    - **Barra de Tiempo:** Añade un nodo `ProgressBar` (o `TextureProgressBar`). Renómbralo a `TimeBar`.
      - **Recomendación:** Si usas `TextureProgressBar`, asigna texturas para `Under` (fondo) y `Progress` (relleno) en el Inspector.
      - Configura su posición (generalmente en la parte superior de la pantalla) y tamaño.
    - **Indicadores de Advertencia/Vidas:** Añade un nodo `HBoxContainer`. Renómbralo a `WarningIndicatorsContainer`.
      - Configura su posición (por ejemplo, cerca de la barra de tiempo).
      - Dentro de `WarningIndicatorsContainer`, añade 2 o 3 nodos `TextureRect` (o `Label`) para representar las advertencias/vidas. Renómbralos a `Warning1`, `Warning2`, etc. Asigna una textura para el estado "activo" de la advertencia (por ejemplo, un icono de exclamación).
    - Añade un nodo `Label`. Renómbralo a `DistanceLabel`. Configura su posición, fuente y estilo.
    - Añade un nodo `Panel`. Renómbralo a `QuestionPanel`. Configura su posición y tamaño para que contenga las preguntas y respuestas.
    - Dentro de `QuestionPanel`, añade un `Label`. Renómbralo a `QuestionLabel`.
    - Dentro de `QuestionPanel`, añade un `VBoxContainer` (o `HBoxContainer` si prefieres) como hijo de `QuestionPanel`. Renómbralo a `AnswersBox`.
    - **¡IMPORTANTE!** Dentro de `AnswersBox`, añade **exactamente 4 nodos `Button`**. Renómbralos a `AnswerButton1`, `AnswerButton2`, `AnswerButton3`, `AnswerButton4`. Configura su texto y estilo.
5.  **¡PASO CLAVE! Conectar Nodos al Script `HUD.gd`:**
    - Selecciona el nodo raíz `InGameHUD`.
    - En el `Inspector`, en la sección `Script Variables`, verás los campos exportados del script `HUD.gd`:
      - `Time Bar`
      - `Warning Indicators Container`
      - `Distance Label`
      - `Question Label`
      - `Answers Container`
    - **Arrastra cada nodo correspondiente** (desde tu árbol de escena: `TimeBar`, `WarningIndicatorsContainer`, `DistanceLabel`, `QuestionLabel`, `AnswersBox`) a su campo respectivo en el Inspector.
6.  **Guardar Escena:** Guarda la escena como `InGameHUD.tscn` en `res://scenes/ui/`.

## 5. Crear la Escena del Diálogo (`GUI_Dialog.tscn`)

Esta escena muestra los cuadros de diálogo de la historia.

1.  **Crea/Abre tu escena `GUI_Dialog.tscn`**. Usa un `CanvasLayer` como nodo raíz.
2.  **Construye la Interfaz (dentro de `GUI_Dialog`):**
    - Añade un `TextureRect` (para el fondo del cuadro de diálogo).
    - Dentro de ese `TextureRect`, añade otro `TextureRect` (para el marco del avatar).
    - Dentro del segundo `TextureRect`, añade un `TextureRect` llamado `avatar` (para la imagen del personaje).
    - Añade un nodo **`Panel`** llamado `Dialog` como hijo directo del nodo raíz `GuiDialog`. (¡RECOMENDADO: Usar `Panel` en lugar de `Control` para visibilidad por defecto!)
    - Dentro de `Dialog`, añade un `Control` (o `Panel`) llamado `ContainerText`.
    - Dentro de `ContainerText`, añade un `Label` llamado `Name` (para el nombre del personaje).
    - Dentro de `ContainerText`, añade un **`DialogueLabel`** llamado `Text` (¡IMPORTANTE! Este es el nodo del plugin para el texto del diálogo).
    - Añade un nodo `AudioStreamPlayer` como hijo directo del nodo raíz `GuiDialog`. **Renómbralo a `TypewriterSound`**. Arrastra tu archivo de sonido de "tecleo" a la propiedad `Stream` de este nodo (si el plugin no lo maneja directamente).
3.  **Adjunta el script `GuiDialog.gd`** al nodo raíz `GuiDialog`.
4.  **¡PASO CLAVE! Conectar Nodos al Script `GuiDialog.gd`:**
    - Selecciona el nodo raíz `GuiDialog`.
    - En el `Inspector`, en la sección `Script Variables`, verás los campos exportados del script `GuiDialog.gd`:
      - `Name Label`
      - `Text Label` (Arrastra el nodo `Text` - DialogueLabel)
      - `Avatar Texture`
      - `Typewriter Sound`
      - `Dialog Node` (Arrastra el nodo `Dialog` - Panel/Control)
      - **`Dialogue Resource` (¡NUEVO!):** Arrastra tu archivo de diálogo `res://data/intro_dialogue.dialogue` a este campo.
    - **Arrastra cada nodo correspondiente** (desde tu árbol de escena: `Name`, `Text`, `avatar`, `TypewriterSound`, `Dialog`, y el archivo `.dialogue`) a su campo respectivo en el Inspector.
5.  **Guardar Escena:** Asegúrate de que la escena esté guardada como `GUI_Dialog.tscn` en `res://scenes/ui/`.

## 6. Construir la Escena Principal del Juego (`Level.tscn`)

Esta escena une todo.

1.  **Crea/Abre tu escena `Level.tscn`**. Usa un `Node2D` como nodo raíz.
2.  **Adjunta el script `Level.gd`** al nodo raíz `Level`.
3.  **Añadir Cámara:** Añade un nodo `Camera2D` como hijo de `Level`. Activa su propiedad `Enabled`.
4.  **Fondo Parallax:**
    - Añade un nodo `ParallaxBackground` como hijo de `Level`.
    - Dentro de `ParallaxBackground`, añade tres nodos `ParallaxLayer`.
    - En cada `ParallaxLayer`, añade un `Sprite2D` y asígnale una de tus imágenes de fondo (`back-buildings.png`, `far-buildings.png`, `foreground.png`).
    - **Importante:** Ajusta la propiedad `Motion -> Mirroring` de cada `ParallaxLayer` con el ancho de tu imagen (e.g., `X: 1920, Y: 0`) para que el fondo se repita infinitamente.
    - Ajusta la propiedad `Motion -> Scale` de cada capa para crear el efecto de profundidad (e.g., `back: 0.1`, `far: 0.5`, `foreground: 1.0`).
5.  **Instanciar Vehículos:**
    - Arrastra una instancia de `PlayerCar.tscn` a tu escena `Level`.
    - Arrastra una instancia de `PoliceCar.tscn` a tu escena `Level`.
6.  **Instanciar Interfaces:**
    - Arrastra una instancia de `InGameHUD.tscn` a tu escena `Level`.
    - Arrastra una instancia de `GUI_Dialog.tscn` a tu escena `Level`.
7.  **¡PASO CLAVE! Conectar Nodos al Script `Level.gd`:**

    - Selecciona el nodo raíz `Level`.
    - En el `Inspector`, verás los campos exportados del script `Level.gd`:
      - `Player Car`
      - `Police Car`
      - `In Game Hud`
      - `Gui Dialog`
      - `Initial Police Offset` (aquí puedes ajustar la distancia inicial de la policía)
    - **Arrastra cada instancia de escena correspondiente** (`PlayerCar`, `PoliceCar`, `InGameHUD`, `GUI_Dialog`) a su campo respectivo en el Inspector.

    **¡IMPORTANTE! Configuración del GameManager:**

    - Selecciona el nodo `GameManager` en tu árbol de escena (o en la pestaña `Autoload`).
    - En el `Inspector`, en la sección `Script Variables`, verás el campo **`Intro Dialogue Resource` (¡NUEVO!)**.
    - **Arrastra tu archivo de diálogo `res://data/intro_dialogue.dialogue`** a este campo.

## 7. ¡Jugar!

1.  Ve a `Proyecto -> Ajustes del Proyecto -> Aplicación -> Configuración`.
2.  En `Run -> Main Scene`, selecciona tu archivo `Level.tscn`.
3.  Presiona `F5` para ejecutar el proyecto.

¡Con esta guía detallada, deberías poder configurar todo sin problemas!
