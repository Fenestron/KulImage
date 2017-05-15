/**
 * Стиль рисования, основанный на "движущейся точке". 
 * В итоге получаются "червячки", которые постепенно вырисовывают картину.
 * В зависимости от изменения параметров меняется поведение этих "червячков".
 * 
 */
class WormsStyle extends Style {
  public WormsStyle() {
    super();
    super.fps = fps;
    super.stylename = stylename;
    setControls(this);
  }

  String stylename = "Worms Style";

  int fps = 1000;

  // Основные переменные стиля

  // Вектор передвижения
  private PVector aims = new PVector();
  // Список Seeker'ов
  private ArrayList < Seeker > seekers;
  private float seekX, seekY;
  // Максимальная длина "червяка"
  private int maxLength;
  // Массив, в котором хранится количество посещений каждого пикселя
  private int[] buffer;
  // Количество Seeker'ов
  private int seekNum;
  public float inertia;
  // Ширина и длина области рисования
  private int imgWidth;
  private int imgHeight;
  // Минимальный порог яркости
  public int brightMin;
  // Максимальный порог яркости
  public int brightMax;

  // Количество пикселей, которые будут рассмотрены вокруг текущего пикселя
  private int amplitude;
  // Ограничение на радиус окружности в векторе отклонения
  private float devMax;
  // Ограничение на радиус окружности в векторе скорости
  private float vMax;

  // Размер (радиус) кисти 
  public float weight;

  /**
   * Установить параметры "по умолчанию"
   */
  public void setup() {

    imgWidth = img.width;
    imgHeight = img.height;

    pg.fill(0);

    seekNum = 2; // 200
    pg.fill(255);
    pg.stroke(255);
    //pg.rect( 0, 0, imgWidth, imgHeight );
    buffer = new int[imgHeight * imgWidth];
    pg.smooth();
    inertia = 6; // 6
    weight = .2; // .2
    brightMax = 200; // 200
    brightMin = 0; // 0
    amplitude = 1; // 1
    maxLength = 30; // 300
    devMax = 4; // 4
    vMax = 50; // 50

    variables = new ArrayList < Variable > ();

    variables.add(new Variable("Длина", "maxLength", 2, 500, maxLength));
    variables.add(new Variable("Округлость", "devMax", 1, 20, devMax));
    variables.add(new Variable("Ломанность", "vMax", 1, 100, vMax));
    variables.add(new Variable("Амплитуда", "amplitude", 0, 10, amplitude));
    variables.add(new Variable("min яркость", "brightMin", 0, 255, brightMin));
    variables.add(new Variable("max яркость", "brightMax", 0, 255, brightMax));
    variables.add(new Variable("Жирность", "weight", 0.001, 1, weight));

    // Синхронизация переменных между переменными интерфейса и класса
    for (Variable
      var: variables) {
      controlP5.Controller controller = cp5.getController(var.varName);
      if (controller != null) {
        controller.setValue(controller.getValue());
      }
    }


    pg.strokeJoin(ROUND);
    seekers = new ArrayList < Seeker > ();

    for (int i = 0; i < seekNum; i++) {

      Seeker mSeeker = new Seeker(new PVector(random(imgWidth), random(imgHeight)), new PVector(random(-3, 3), random(-3, 3)), inertia);

      while ((brightness(mSeeker.getImgPixel()) > brightMax) || (brightness(mSeeker.getImgPixel()) < brightMin)) {

        mSeeker.setP(int(random(imgWidth)), int(random(imgHeight)));
      }
      seekers.add(mSeeker);
    }
  }

  /**
   * Одна итерация отрисовки данным стилем.
   * 
   */
  public void draw() {
    for (int i = 0; i < seekNum; i++) {
      Seeker mSeeker = seekers.get(i);
      drawing(mSeeker);
    }
  }

  /**
   * Итерация отрисовки для одного Seeker'a
   * 
   * Для каждого Seeker'a ищем вектор передвижения
   * и рисуем продолжение в соответствии с этим вектором.
   */
  private void drawing(Seeker mySeeker) {

    aims.x = 0;
    aims.y = 0;

    seekX = mySeeker.getP().x;
    seekY = mySeeker.getP().y;

    while (isBrush && (sq(xcord - seekX) + sq(ycord - seekY) > sq(sq(radius)) + 100)) {
      deplacePoint(mySeeker);
      seekX = mySeeker.getP().x;
      seekY = mySeeker.getP().y;
    }

    // Местоположение тестируемой точки в pixels[]
    int pixelsPosition = floor(seekX) + floor(seekY) * imgWidth;

    int locX = floor(seekX);
    int locY = floor(seekY);

    // Вычисление барицентра
    for (int i = -amplitude; i < amplitude + 1; i++) {
      for (int j = -amplitude; j < amplitude + 1; j++) {
        int locTaX = locX + i;
        int locTaY = locY + j;
        // Проверка корректности координат 
        if ((locTaX > 0) && (locTaY > 0) && (locTaX < imgWidth - 1) && (locTaY < imgHeight - 1)) {
          int brightnessTemp = int(brightness(img.pixels[locTaX + imgWidth * locTaY]));
          aims.sub(new PVector(i * brightnessTemp, j * brightnessTemp));
        }
      }
    }

    // Объединяем вектора
    aims.normalize();
    aims.mult(100f / mySeeker.getInertia());
    mySeeker.getV().add(new PVector(aims.x, aims.y));
    PVector deviation = mySeeker.getV().get();
    deviation.normalize();
    deviation.mult(devMax);
    mySeeker.getV().normalize();
    mySeeker.getV().mult(vMax);
    mySeeker.getP().add(deviation);

    // Увеличиваем длину и перемещаемся дальше
    mySeeker.setLongueur(mySeeker.getLongueur() + 1);

    if (mySeeker.getLongueur() > maxLength) {
      deplacePoint(mySeeker);
    }
    if ((mySeeker.getP().x < 1) || (mySeeker.getP().y < 1) || (mySeeker.getP().x > imgWidth - 1) || (mySeeker.getP().y > imgHeight - 1)) {
      deplacePoint(mySeeker);
      return;
    }

    // Увеличиваем количество "посещений" каждого пикселя 
    buffer[pixelsPosition]++;

    // Действия, завязанные на количестве "посещений" каждой точки.

    // if (buffer[pixelsPosition]++ > 0) return;

    // Рисование 
    mySeeker.setDia((float)(weight * (1 - cos((mySeeker.getLongueur()) * PI * 2 / (float) maxLength))));
    mySeeker.setAlpha((max(0, (round(127 * mySeeker.getDia() / weight)))));

    int x = (int) mySeeker.getP().x;
    int y = (int) mySeeker.getP().y;

    color c;
    c = img.get(x, y);

    pg.fill(c);
    pg.stroke(c, mySeeker.getAlpha());
    pg.strokeWeight(mySeeker.getDia());

    float startX = seekX;
    float startY = seekY;
    float stopX = mySeeker.getP().x;
    float stopY = mySeeker.getP().y;

    // if ((sq(xcord - stopX) + sq(ycord - stopY) > sq(radius)))
    //   return;

    pg.line(startX, startY, stopX, stopY);
  }

  /**
   * Функция перемещения Seeker'a
   */
  private void deplacePoint(Seeker seeker) {
    seeker.setLongueur(0);
    setRandomP(seeker);
    while ((brightness(seeker.getImgPixel()) > brightMax) ||
      (brightness(seeker.getImgPixel()) < brightMin)) {
      setRandomP(seeker);
    }
    seekX = seeker.getP().x;
    seekY = seeker.getP().y;
  }

  /**
   * Установка случайной координаты
   */
  private void setRandomP(Seeker seeker) {
    if (isBrush) {
      seeker.setP(xcord + random(-radius, radius), ycord + random(-radius, radius));
    } else {
      seeker.setP(random(1, imgWidth - 1), random(1, imgHeight - 1));
    }
  }


  /**
   * "Бегун", которые представляет из себя передвигающуюся точку.
   * 
   */
  public class Seeker {

    // Текущая позиция
    private PVector p = new PVector();
    // Конечная позиция
    private PVector v = new PVector();
    private int imgPixel;
    private float inertia;
    // Длина
    private float longueur;
    // Диаметр
    private float dia;
    private int alpha;

    public Seeker(PVector P, PVector V, float Inertia) {
      p = P;
      v = V;
      longueur = 0;
      setInertia(random(-2, 2) + Inertia);
    }

    public float getLongueur() {
      return longueur;
    }

    public void setLongueur(float longueur) {
      this.longueur = longueur;
    }

    public PVector getP() {
      return p;
    }

    public void setP(float a, float b) {
      this.p.x = a;
      this.p.y = b;
    }

    public PVector getV() {
      return v;
    }

    public float getDia() {
      return dia;
    }

    public void setDia(float dia) {
      this.dia = dia;
    }

    public int getAlpha() {
      return alpha;
    }

    public void setAlpha(int alpha) {
      this.alpha = alpha;
    }

    public float getInertia() {
      return inertia;
    }

    public void setInertia(float inertia) {
      this.inertia = inertia;
    }

    public int getImgPixel() {
      if (getP().x > 0 && getP().x < imgWidth && getP().y > 0 && getP().y < imgHeight)
        return img.pixels[floor(getP().x) + floor(getP().y) * imgWidth];
      else {
        return 0;
      }
    }
  }
}