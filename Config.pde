import controlP5.*;
import processing.serial.*;
import drop.*;
import processing.awt.PSurfaceAWT;


PImage img; // Загруженное изображение
PGraphics pg; // Холст, на котором рисуется картина (backend)
Painter painter; // "Художник", который рисует картину

SDrop drop;
String dropStr = "Перетащите изображение\nИли кликните здесь для выбора файла";

ControlFrame cf;
ControlP5 cp5;
PApplet parent;


// Главные константы интерфейса ControlFram'a
int mainOffsetX = 25;
int mainOffsetY = 50;
int groupSizeX = 350;
int groupSizeY = 250;
int groupOffsetX = 25;
int groupOffsetY = 235;
int inGroupOffsetX = 15;
int inGroupOffsetY = 35;

int buttonSizeX = 150;
int buttonSizeY = 25;

PFont pfont;
ControlFont font;

int cfSizeX = 400;

int tabHeight = 22;


// Длина и ширина области рисования
int dWidth;
int dHeight;
int dWidthI;
int dHeightI;

int maxWidth;
int maxHeight;


float xcord;
float ycord;
float radius = 20;
boolean isBrush = false;
boolean newImg = false;