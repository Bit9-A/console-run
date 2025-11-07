# Instrucciones de Ensamblaje Final - Cyber-Escape (v4 - A prueba de errores)

Esta es la guía definitiva. Hemos hecho los scripts más flexibles para que puedas organizar tus escenas como prefieras.

## 1. Configurar los Singletons (Autoloads)

Asegúrate de que estos tres scripts estén en `Proyecto -> Ajustes del Proyecto -> Autoload`:

- `GameManager`
- `QuestionManager`
- `DialogueManager`

## 2. Construir la Escena de Diálogo (`GUI_Dialog.tscn`)

1.  **Crea/Abre tu escena `GUI_Dialog.tscn`**. Usa un `CanvasLayer` como nodo raíz.
2.  **Añade un `AudioStreamPlayer`** llamado `TypewriterSound` y asígnale un sonido.
3.  **Adjunta el script `GuiDialog.gd`** al nodo raíz.
4.  **¡NUEVO PASO CLAVE!** Selecciona el nodo raíz `GuiDialog`. En el `Inspector`, verás varios campos vacíos:
	- `Name Label`
	- `Text Label`
	- `Avatar Texture`
	- `Typewriter Sound`
	- **Arrastra cada nodo correspondiente** desde tu árbol de escena al campo correcto en el Inspector.

## 3. Crear la Escena del HUD (`InGameHUD.tscn`)

1.  **Crea tu escena `InGameHUD.tscn`**. Usa un `CanvasLayer` como nodo raíz.
2.  **Adjunta el script `HUD.gd`** al nodo raíz.
3.  **Construye tu interfaz** dentro de la escena (el `DistanceLabel`, `QuestionPanel`, etc.).
4.  **¡NUEVO PASO CLAVE!** Selecciona el nodo raíz `InGameHUD`. En el `Inspector`, verás campos vacíos:
	- `Distance Label`
	- `Question Label`
	- `Answers Container` (aquí debes arrastrar el nodo `VBoxContainer` o `HBoxContainer` que contiene tus 4 botones de respuesta).
	- **Arrastra cada nodo correspondiente** desde tu árbol de escena al campo correcto.

## 4. Construir la Escena Principal (`Level.tscn`)

1.  Abre tu escena `Level.tscn`.
2.  **Instancia tus escenas de UI:** Arrastra `InGameHUD.tscn` y `GUI_Dialog.tscn` a tu escena `Level`.
3.  **Conecta los Nodos Principales:**
	- Selecciona el nodo raíz `Level`.
	- En el `Inspector`, arrastra tus nodos `PlayerCar`, `PoliceCar` y la instancia de `InGameHUD` a los campos `Player Car`, `Police Car` y `In Game Hud`.

## 5. ¡Jugar!

Con este método, las rutas a los nodos ya no están "hardcodeadas" en el código, sino que las asignas tú visualmente. Esto elimina los errores "Node not found" y te da total libertad para estructurar tus escenas.

¡Ahora sí, todo debería funcionar!
