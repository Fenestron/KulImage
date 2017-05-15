/**
 * Метод с предварительными настройками
 */
void settings() {
  dWidth = dWidthI = displayWidth - 500;
  dHeight = dHeightI = displayHeight - 300;
  maxWidth = displayWidth - 500;
  maxHeight = displayHeight - 300;

  size(dWidth, dHeight);

  parent = this;
  cf = new ControlFrame(cfSizeX, dHeight);
  cf.getSurface().setVisible(false);
}

/**
 * Установка основных рабочих элементов программы
 */
void setup() {

  surface.setResizable(false);

  PImage icon = loadImage("icon.png");

  if (icon != null) {
    surface.setIcon(icon);
  }

  drop = new SDrop(this);

  surface.setLocation(20, 20);
  surface.setTitle("KulImage");

  background(255);

  noStroke();
  smooth();

  pg = createGraphics(dWidth, dHeight);

  pg.beginDraw();

  pg.noStroke();
  pg.smooth();
  pg.textSize(64);
  pg.fill(0, 102, 153);
  pg.text(dropStr, dWidth / 4, 70);

  pg.endDraw();

  registerMethod("pre", this);

  surface.setLocation(20, 20);
}

/**
 * Изменение размера окна с картиной.
 */
void pre() {

  if (img == null) {
    cf.getSurface().setVisible(false);
    return;
  }

  dWidthI = width;
  dHeightI = height;
  if (dHeightI * img.width > dWidthI * img.height) {
    dWidth = dWidthI;
    dHeight = dWidth * img.height / img.width;
  } else {
    dHeight = dHeightI;
    dWidth = dHeight * img.width / img.height;
  }
}

/**
 * Метод рисования.
 */
void draw() {
  background(255);

  if (img == null) {
    noStroke();
    smooth();
    textAlign(CENTER);
    textSize(width / 30);
    fill(0, 102, 153);
    text(dropStr, max(width / 2, 100), height / 3);
    return;
  }

  image(pg, 0, 0, dWidth, dHeight);
}

/**
 * Метод, который срабатывает при нажатии любой клавиши.
 */
void keyPressed() {
  if (key == ESC) {
    key = 0; 
  }
}

/**
 * Метод, срабатывающий при нажатии кнопки мыши.
 */
void mousePressed() {
  while (cp5 == null)
    delay(1);

  if (isBrush) {
    if (!painter.isAlive) {
      painter.start();
    }
    painter.enable();
    return;
  }

  selectInput("Открытие", "imageOpen");
}

void mouseReleased() {
  if (isBrush) {
    painter.disable();
    return;
  }
}

void mouseDragged() {
  try {
    xcord = mouseX * ((float) img.width / dWidth);
    ycord = mouseY * ((float) img.height / dHeight);
  } catch (Exception e) {}
}

void mouseMoved() {
  if (isBrush) {
    cursor(HAND);
  } else {
    cursor(ARROW);
  }

  try {
    xcord = mouseX * ((float) img.width / dWidth);
    ycord = mouseY * ((float) img.height / dHeight);
  } catch (Exception e) {}
}


void imageOpen(File selection) {
  if (selection != null) {
    img = loadImage(selection.getAbsolutePath());
    if (img == null) {
      return;
    }

    loadPicture();
  }
}

void saveImage(File selection) {
  if (selection != null) {
    String path = selection.getAbsolutePath();

    if (!path.endsWith(".png"))
      path += ".png";
    
    pg.save(path);
  }
}