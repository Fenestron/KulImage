class Painter extends Thread {

  volatile boolean isActive = false;
  volatile boolean isAlive = false;
  volatile int fps;
  int maxFps;

  Style style;

  Painter(String stylename) {
    style = getStyle(stylename);
    maxFps = style.fps;
    fps = style.fps;

    //pg.beginDraw();

    //pg.image(img, 0, 0);
    //pg.filter(THRESHOLD, 0.1);
    //pg.filter(BLUR, 7);

    //pg.endDraw();
  }

  void enable() {
    //style.setup();
    isActive = true;
  }

  void reset() {
    style.setup();
  }

  void start() {
    //loop();
    isAlive = true;
    isActive = true;
    super.start();
    cp5.getTab(style.stylename).bringToFront();
  }

  boolean getActive() {
    return isActive;
  }

  void disable() {
    isActive = false;
    pg.endDraw();
  }

  void kill() {
    disable();
    isAlive = false;

  }

  void draw() {
    pg.beginDraw();
    for (int i = 0; i < fps; ++i) {
      //if (isActive)
      try {
        style.draw();
      } catch (Exception e) {
        break;
      }
    }

    pg.endDraw();
  }

  void run() {
    while (isAlive) {
      while (isActive) {
        draw();
      }
    }
  }
}