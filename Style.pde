/**
 * Абстрактный класс для описания шаблона стиля.
 */
abstract class Style {
  public Style() {
    while (pg == null)
      delay(10);

    pg.beginDraw();
    this.setup();
    pg.endDraw();
  }

  private int fps;

  public String stylename;

  public ArrayList < Variable > variables;

  public abstract void draw();

  public abstract void setup();

  public void setControls(Style style) {

    String stylename = style.stylename;

    ArrayList < Style.Variable > variables = style.variables;

    cp5.blockDraw = true; // Заблокировать отрисовку 

    cp5.addTab(stylename)
      // .setColorBackground(color(0, 160, 100))
      .setColorLabel(color(255))
      .setColorActive(color(255, 128, 0))
      .setHeight(tabHeight)
      .getCaptionLabel().setFont(font);

    cp5.getTab(stylename)
      .activateEvent(true);

    Group g1 = cp5.addGroup(stylename)
      .setPosition(groupOffsetX, groupOffsetY)
      .setBackgroundHeight(100)
      .setBackgroundColor(color(255, 50))
      .setSize(groupSizeX, groupSizeY)
      .setTab(stylename)
      .hideBar();

    int mulPosX = 0;

    // Добавление элементов управления переменными на ControlFrame

    for (Style.Variable
      var: variables) {
      cp5.addSlider(var.varName).plugTo(style,
          var.varName)
        .setRange(var.rangeLeft,
          var.rangeRight)
        .setValue(var.value)
        .setPosition(inGroupOffsetX, 10 + inGroupOffsetY * mulPosX++)
        .setSize(200, 20)
        .setLabel(var.label)
        .setGroup(g1)
        .setFont(font);
    }

    cp5.blockDraw = false; // Разблокировать отрисовку
  }


  public int getFps() {
    return fps;
  }

  /**
   * Класс для хранения переменных 
   */
  public class Variable {
    Variable(String label, String varName, float rangeLeft, float rangeRight, float value) {
      this.label = label;
      this.varName = varName;
      this.rangeLeft = rangeLeft;
      this.rangeRight = rangeRight;
      this.value = value;
    }

    private String label; // Надпись на Элементе управление
    private String varName; // Название переменной 
    private float rangeLeft; // Левая граница слайдера
    private float rangeRight; // Правая граница слайдера
    private float value; // Начальное значение
  }
}