using System;
using System.IO;
using PictureTime;
using PointStuff;


namespace Main
{
    class Program
    {
        static void Main(string[] args)
        {


            var my_image = new Image(200, 200, new Colour(50,50,50));

            my_image.AddLineToImage(new Coord(0,0), new Coord(199, 99), new Colour(100,0, 0));
            my_image.AddLineToImage(new Coord(0, 190), new Coord(199,99), new Colour(0, 100, 0));

            var image_name = "my_very_cool_image.ppm";
            WriteImageToDesktop(my_image, image_name);
        }

        static void WriteImageToDesktop(Image image, string image_name)
        {
            var desktop_path = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
            var full_path = Path.Combine(desktop_path, image_name);
            var writer = new StreamWriter(full_path);
            writer.WriteLine("P3");
            writer.WriteLine($"{image.Width} {image.Height}");
            writer.WriteLine("255");

            for (int y = image.Height-1; y >= 0; y--)
            {
                for (int x = 0; x < image.Width; x++)
                {
                    Colour pixel = image.GetPixel(x, y);
                    writer.Write($"{pixel.R} {pixel.G} {pixel.B} ");
                }
            }
            writer.Close();
        }
    }
}
