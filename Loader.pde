Style getStyle(String name) {
  Style style;
  switch (name) {
    case ("Embroidery"):
      style = new EmbroideryStyle();
      break;
    case ("Worms"):
      style = new WormsStyle();
      break;
    case ("Wand"):
      style = new WandStyle();
      break;
    default:
      style = new WormsStyle();
  }

  return style;
}

public void loadPicture() {

  newImg = true;

  if (painter != null) {
    painter.disable();
    painter.reset();
    cp5.getController("startButton").setLabel("Пуск");
  }

  if (maxHeight * img.width > maxWidth * img.height) {
    dWidth = dWidthI;
    dHeight = dWidth * img.height / img.width;
  } else {
    dHeight = dHeightI;
    dWidth = dHeight * img.width / img.height;
  }

  surface.setSize(dWidth, dHeight);

  pg = createGraphics(img.width, img.height);
  pg.beginDraw();
  pg.image(img, 0, 0);
  pg.endDraw();

  cf.loop();
}