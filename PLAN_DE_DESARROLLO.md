# Plan de Desarrollo: MVP Escalable "Coche de Cifra"

Este documento detalla la arquitectura, estructura y fases de desarrollo para crear un prototipo funcional y escalable del juego "Coche de Cifra" utilizando Godot Engine.

## 1. Filosofía y Arquitectura

El objetivo es construir un MVP sólido que sea fácil de mantener y ampliar. Para ello, nos basaremos en dos principios clave:

- **Modularidad:** Cada componente del juego (jugador, enemigo, UI) será una escena independiente y autocontenida.
- **Desacoplamiento:** Los componentes no se comunicarán directamente entre sí. Usaremos el sistema de **señales** de Godot para que los objetos emitan eventos sin saber quién los escucha. Esto evita el "código espagueti" y facilita la adición de nuevas funcionalidades.

## 2. Estructura de Carpetas del Proyecto

Una organización clara es fundamental. Crearemos la siguiente estructura:

```
/
|-- assets/         # Recursos visuales y de audio
|   |-- fonts/
|   |-- sprites/
|   `-- sfx/
|
|-- data/           # Archivos de datos externos (JSON)
|   `-- questions.json
|
|-- scenes/         # Todas las escenas .tscn
|   |-- player/
|   |-- enemies/
|   |-- ui/
|   `-- levels/
|
|-- scripts/        # Todos los scripts .gd
|   |-- player/
|   |-- enemies/
|   |-- ui/
|   `-- singletons/
|
`-- project.godot   # Archivo principal del proyecto
```

## 3. Singletons / Autoloads (Gestores Globales)

Configuraremos scripts globales para manejar sistemas centrales, accesibles desde cualquier parte del juego.

- **`GameManager.gd`**: Controlará el estado general del juego (ej. `MENU`, `JUGANDO`, `GAME_OVER`) y la carga de escenas.
- **`QuestionManager.gd`**: Se encargará de cargar las preguntas desde `questions.json`, mezclarlas y proporcionar una pregunta nueva cuando se solicite.

---

## 4. Fases de Desarrollo del MVP

### Fase 0: Estructura del Proyecto

- **Tarea 1:** Crear la estructura de carpetas descrita anteriormente.
- **Tarea 2:** Crear los scripts vacíos para los Singletons (`GameManager.gd`, `QuestionManager.gd`) y configurarlos en los `Autoload` del proyecto.
- **Tarea 3:** Crear un archivo `data/questions.json` con 2-3 preguntas de ejemplo.

### Fase 1: El Coche y el Movimiento

- **Tarea 1:** Crear la escena principal del juego (`Main.tscn`).
- **Tarea 2:** Crear la escena del jugador (`scenes/player/Player.tscn`) con un nodo `CharacterBody2D`, `CollisionShape2D` y un `Sprite2D` temporal.
- **Tarea 3:** Crear el script `scripts/player/Player.gd` para controlar el movimiento (acelerar, frenar, girar) con las teclas de flecha.
- **Tarea 4:** Instanciar al jugador en `Main.tscn`.

### Fase 2: La Interfaz de Hacking (HUD)

- **Tarea 1:** Crear la escena del HUD (`scenes/ui/HUD.tscn`).
- **Tarea 2:** Diseñar la interfaz con nodos `Label` para la pregunta, las opciones (A, B, C, D) y el temporizador.
- **Tarea 3:** Crear el script `scripts/ui/HUD.gd`.
- **Tarea 4:** Implementar la lógica en `HUD.gd`:
  - Al iniciarse, solicitar una pregunta a `QuestionManager`.
  - Mostrar la pregunta y las opciones.
  - Iniciar un temporizador (`Timer` node).
  - Definir señales: `respuesta_seleccionada(respuesta)`, `tiempo_agotado`.
- **Tarea 5:** Conectar las señales del HUD en `Main.tscn` para gestionar la lógica de acierto/fallo.

### Fase 3: La Amenaza Policial

- **Tarea 1:** Crear la escena de la patrulla (`scenes/enemies/Patrol.tscn`) con `CharacterBody2D`, `CollisionShape2D` y un `Sprite2D` temporal.
- **Tarea 2:** Crear el script `scripts/enemies/Patrol.gd` con una IA simple: moverse hacia la posición del jugador.
- **Tarea 3:** En `Main.tscn`, crear una función para instanciar (`spawn`) patrullas periódicamente.
- **Tarea 4:** Implementar la lógica de colisión: si una patrulla toca al jugador, emitir una señal `jugador_atrapado` desde el jugador.
- **Tarea 5:** `GameManager` escuchará la señal `jugador_atrapado` para cambiar el estado a `GAME_OVER`.

### Fase 4: Los Hacks de Ventaja

- **Tarea 1:** En `HUD.tscn`, añadir un espacio para los íconos de los hacks.
- **Tarea 2:** Implementar el hack "Fallo en la Matriz":
  - El jugador empieza con este hack.
  - Al pulsar una tecla (ej. `Espacio`), el jugador emite una señal `hack_activado("fallo_matriz")`.
  - El `HUD` escucha esta señal y pausa el temporizador de la pregunta actual durante unos segundos.
  - El ícono del hack en el HUD se muestra como "usado".

---

Una vez completadas estas fases, tendremos un bucle de juego funcional que servirá como una base excelente para añadir los gráficos, sonidos, más contenido y pulir la experiencia.
