
import com.hamoid.*;
import java.util.*;

VideoExport videoExport;

PImage img1;
PImage img2;
PImage mask;

color purple = color(127, 0, 127);
color white = color(255, 255, 255);

int width = 938;
int height = 620;

Map<String, Float> iceData = new HashMap<String, Float>();

public static class Utils{
  public static DateTime GetNonLeapYear(){
    return new DateTime(2001,1,1,0,0,0,0);
  }
  
  public static String GetFilenameForDate(String path, int year, int dayOfYear){
    File f;
    String filename;
    
    // Years up to 1988 only have data for every second day so if png doesn't exist then try the next day
    do{
      DateTime dt = GetNonLeapYear().withDayOfYear(dayOfYear);
            
      int month = dt.monthOfYear().get();
      int day = dt.dayOfMonth().get();
      
      filename = String.format( path+"..\\combinedPngs\\nt_%d%02d%02d_n.png", year, month, day);
      f = new File(filename);
      
      dayOfYear++;
      if(dayOfYear > 365) dayOfYear = dayOfYear - 3; // Don't go to the next next, simply skip back a few days - close enough!
    }
    while(!f.exists());
    
    return f.getAbsolutePath();
  }
}

public void loadIceData()
{
  String[] lines = loadStrings("nsidc_global_nt_final_and_nrt.txt");
  
  for (String line : lines) {
    if(line.charAt(0) == '#' || line.charAt(0) == ' ') continue;
    String[] data = split(line, ',');
    iceData.put(data[0], float(trim(data[3])));
  }
}

void setup(){
  loadIceData();
  size(938, 620);
  mask = loadImage("..\\combinedPngs\\mask_n.png").get(18,29,306,448);
    
  frameRate(30);
  videoExport = new VideoExport(this);
  videoExport.setFrameRate(30);
  videoExport.startMovie();
}


int dayOfYear = 1;

void draw(){
  fill(purple);
  background(purple);
  
  img1 = loadImage(Utils.GetFilenameForDate(sketchPath(""), 1979, dayOfYear)).get(18,29,306,448);
  img1.filter(GRAY);
  image(img1,10,100);
  image(img1,305+10,100);
  
  img2 = loadImage(Utils.GetFilenameForDate(sketchPath(""), 2016, dayOfYear)).get(18,29,306,448);
  img2.filter(GRAY);
  image(img2,305*2+10,100);
  
  blend(img2, 0, 0, 305, 447, 305+10, 100, 305, 447, SUBTRACT);
  
  image(mask,10,100);
  image(mask,305+10,100);
  image(mask,610+10,100);
  
  DateTime dt = Utils.GetNonLeapYear().plus(Period.days(dayOfYear));
  
  String month = dt.monthOfYear().getAsText();
  fill(white);
  textSize(25);
  textAlign(CENTER);
  text("Arctic sea ice concentration difference between 1979 and 2016", width/2,25);
  text(month, width/2, height - 25);
  text("1979", 305/2 +10 , 90);
  text("Difference", 305/2 + 305 +10, 90);
  text("2016", 305/2 + 305*2 +10, 90);
  text("@kevpluck", width/2, 57);
  
  Float iceArea1979 = iceData.get(String.format("1979-%02d-%02d 12:00", dt.monthOfYear().get(), dt.dayOfMonth().get()));
  Float iceArea2016 = iceData.get(String.format("2016-%02d-%02d 12:00", dt.monthOfYear().get(), dt.dayOfMonth().get()));
  
  Float diff = iceArea1979 - iceArea2016;
  
  text(String.format("%.1fM Km²", iceArea1979), 305/2 +10, height - 50);
  text(String.format("%.1fM Km²", diff), 305/2 + 305 +10, height - 50);
  text(String.format("%.1fM Km²", iceArea2016), 305/2 + 305*2 +10, height - 50);
  
  textSize(10);
  text("Sea Ice Concentrations from Nimbus-7 SMMR and DMSP SSM/I-SSMIS Passive Microwave Data (NSIDC-0051), Near-Real-Time DMSP SSMIS Daily Polar Gridded Sea Ice Concentrations", width/2, height - 8);
  
  dayOfYear++;
  if(dayOfYear > 365) {
    noLoop();
    videoExport.endMovie();
  }
  else
    videoExport.saveFrame();
}