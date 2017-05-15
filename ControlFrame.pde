/**
 * Окно настроек стилей
 */
class ControlFrame extends PApplet {

  private int w, h;

  public ControlFrame(int _w, int _h) {
    super();
    w = _w;
    h = _h;
    PApplet.runSketch(new String[] {
      "",
      this.getClass().getName()
    }, this);
    surface.setVisible(false);

  }

  public void settings() {
    size(w, h);
  }

  private String[] controlNames;

  public void setup() {
    surface.setVisible(false);

    PImage icon = parent.loadImage("settings.png");
    if (icon != null) {
      surface.setIcon(icon);
    }

    background(40);

    noLoop();

    removeExitEvent(getSurface());

    surface.setLocation(dWidth + 45, 20);
    surface.setTitle("Control Frame");

    cp5 = new ControlP5(this);

    pfont = createFont("Arial", 16);
    font = new ControlFont(pfont);

    cp5.getTab("default")
      .setCaptionLabel("Main tab")
      .setHeight(tabHeight)
      // .setColorBackground(color(0, 160, 100))
      // .setColorLabel(color(255))
      // .setColorActive(color(255, 128, 0))
      .getCaptionLabel().setFont(font);

    int mulPosY = 0;

    controlNames = new String[] {
      "startButton",
      "clearButton",
      "saveButton",
      "speedSlider",
      "loadButton",
      "originalButton",
      "brush"
    };


    cp5.addButton("startButton")
      .setPosition(mainOffsetX, mainOffsetY + inGroupOffsetY * mulPosY++)
      .setSize(buttonSizeX, buttonSizeY)
      .setCaptionLabel("Пуск")
      .setTab("global")
      .setVisible(false)
      .setFont(font);

    cp5.addButton("clearButton")
      .setPosition(mainOffsetX, mainOffsetY + inGroupOffsetY * mulPosY++)
      .setSize(buttonSizeX, buttonSizeY)
      .setCaptionLabel("Очистить")
      .setTab("global")
      .setVisible(false)
      .setFont(font);

    cp5.addButton("saveButton")
      .setPosition(mainOffsetX, mainOffsetY + inGroupOffsetY * mulPosY++)
      .setSize(buttonSizeX, buttonSizeY)
      .setCaptionLabel("Сохранить")
      .setTab("global")
      .setVisible(false)
      .setFont(font);

    cp5.addSlider("speedSlider")
      .setRange(0, 100)
      .setValue(100)
      .setPosition(mainOffsetX + inGroupOffsetX, mainOffsetY + 10 + inGroupOffsetY * mulPosY++)
      .setSize(200, 20)
      .setFont(font)
      .setLabel("Скорость")
      .setTab("global")
      .setVisible(false);

    cp5.addSlider("radiusSlider")
      .setRange(1, 100)
      .setValue(20)
      .setPosition(mainOffsetX + inGroupOffsetX, mainOffsetY + 10 + inGroupOffsetY * mulPosY++)
      .setSize(200, 20)
      .setFont(font)
      .setLabel("Радиус кисти")
      .setTab("global")
      .setVisible(false);

    mulPosY = 0;

    cp5.addButton("loadButton")
      .setPosition(2 * mainOffsetX + buttonSizeX, mainOffsetY + inGroupOffsetY * mulPosY++)
      .setSize(buttonSizeX, buttonSizeY)
      .setCaptionLabel("Загрузить")
      .setTab("global")
      .setVisible(false)
      .setFont(font);

    cp5.addButton("originalButton")
      .setPosition(2 * mainOffsetX + buttonSizeX, mainOffsetY + inGroupOffsetY * mulPosY++)
      .setSize(buttonSizeX, buttonSizeY)
      .setCaptionLabel("Оригинал")
      .setTab("global")
      .setVisible(false)
      .setFont(font);

    Toggle toggle = cp5.addToggle("brush")
      .setPosition(2 * mainOffsetX + buttonSizeX, mainOffsetY + inGroupOffsetY * mulPosY++)
      .setSize((int)(2.5 * buttonSizeY), buttonSizeY)
      .setValue(true)
      .setVisible(false)
      .setMode(ControlP5.SWITCH)
      .setCaptionLabel("Кисть")
      .setTab("global");

    toggle.getCaptionLabel().getStyle().marginTop = -27;
    toggle.getCaptionLabel().getStyle().marginLeft = 75;
    toggle.getCaptionLabel().setFont(font);

    DropdownList ddl = cp5.addDropdownList("styleChooser")

      .setPosition(width / 4, groupOffsetY)
      .setSize(200, 120)
      .setItemHeight(buttonSizeY)
      .setBarHeight(buttonSizeY + 4)
      .setFont(font)
      .setLabel("Выберите стиль")
      .setTab("default");

    ddl.getCaptionLabel().getStyle().marginTop = 4;
    ddl.getCaptionLabel().getStyle().marginLeft = 25;
    ddl.getValueLabel().getStyle().marginTop = 4;

    ddl.addItem("Worms", "Worms");
    ddl.addItem("Embroidery", "Embroidery");
    ddl.addItem("Wand", "Wand");

    surface.setVisible(false);
  }


  public void draw() {
    background(40);

    if (!isVisible()) {
      getSurface().setVisible(true);
    }
  }

  private boolean isVisible() {
    return ((PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame().isVisible();
  }


  public void startButton() {

    if (!painter.isAlive) { // Если не запущен
      painter.start(); // То запускаем
      if (newImg) {
        pg.beginDraw();
        pg.clear();
        pg.endDraw();
        newImg = false;
      }
      cp5.getController("startButton").setCaptionLabel("Остановить");
      return;
    }

    if (!painter.getActive()) { // Если Остановлен
      painter.enable(); // То возобнавляем работу
      if (newImg) {
        pg.beginDraw();
        pg.clear();
        pg.endDraw();
        newImg = false;
      }
      cp5.getController("startButton").setCaptionLabel("Остановить");
      return;
    }

    if (painter.getActive()) { // Если включен
      painter.disable(); // То выключаем
      cp5.getController("startButton").setCaptionLabel("Пуск");
      return;
    }

  }

  public void clearButton() {
    boolean isEnable = painter.isActive;
    painter.disable();
    delay(30);
    painter.reset();
    pg.beginDraw();
    pg.background(255);
    pg.endDraw();
    delay(30);
    if (isEnable)
      painter.enable();
  }

  public void saveButton() {
    parent.selectOutput("Сохранение", "saveImage");
  }

  public void loadButton() {
    parent.selectInput("Открытие", "imageOpen");
  }

  public void originalButton() {
    pg.beginDraw();
    pg.image(img, 0, 0);
    pg.endDraw();
  }


  public void speedSlider(float fps) {
    if (painter != null) {
      if (fps > 0 & fps <= 2) {
        painter.fps = 1;
        return;
      }
      painter.fps = (int)(painter.maxFps * fps / 100);
    }
  }


  public void brush(boolean theFlag) {
    if (theFlag == true) {
      isBrush = false;
      cp5.getController("radiusSlider").setVisible(false);
      if (painter != null) {
        cp5.getController("startButton").setVisible(true);
        cp5.getController("startButton").setCaptionLabel("Пуск");
        // painter.enable();
      }
    } else {
      isBrush = true;
      cp5.getController("radiusSlider").setVisible(true);
      if (painter != null) {
        if (!painter.isAlive) { // Если не запущен
          painter.start(); // То запускаем
          if (newImg) {
            pg.beginDraw();
            pg.clear();
            pg.endDraw();
            newImg = false;
          }
        }
        cp5.getController("startButton").setVisible(false);
        painter.disable();
      }
    }
  }

  public void radiusSlider(float r) {
    radius = r;
  }


  public void controlEvent(ControlEvent theEvent) {

    if (theEvent.isFrom("styleChooser")) {

      DropdownList ddl1 = (DropdownList) theEvent.getController();
      String stylename = ddl1.getItem((int) ddl1.getValue()).get("value").toString();

      if (painter != null) {
        cp5.getTab(painter.style.stylename).remove();
        painter.kill();
      }

      painter = new Painter(stylename);

      for (String name: controlNames) {
        cp5.getController(name).setVisible(true);
      }

      if (isBrush) {
        cp5.getController("startButton").setVisible(false);
      } else {

      }

      cp5.getController("startButton").setCaptionLabel("Пуск");

      cp5.getTab(painter.style.stylename).bringToFront();
    }
  }

  void keyPressed() {
    if (key == ESC) {
      key = 0;
    }
  }
}


private static final void removeExitEvent(final PSurface surf) {
  final java.awt.Window win = ((processing.awt.PSurfaceAWT.SmoothCanvas) surf.getNative()).getFrame();

  for (final java.awt.event.WindowListener evt: win.getWindowListeners()) {
    win.removeWindowListener(evt);
  }

}