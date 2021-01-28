using System;
using PointStuff;

namespace PictureTime
{

    public struct Colour
    {
        public int R {get; set;}
        public int G {get; set;}
        public int B {get; set;}

        public Colour(int r, int g, int b)
        {
            R = r;
            G = g;
            B= b;
        }
    }
    public class Image
    {
        Colour[,] _image;

        public int Width
        {
            get
            {
                return _image.GetLength(0);
            }
        }
        public int Height
        {
            get
            {
                return _image.GetLength(1);
            }
        }

        public Image(int width, int height, Colour fillcol)
        {
            _image = new Colour[width, height];
            this.Fill(fillcol);
        }

        public void Fill(Colour fillColour)
        {
            for (int y = 0; y < Height; y++)
                for (int x = 0; x < Width; x++)
                {
                    _image[x, y] = fillColour;
                }

        }

        public Colour GetPixel(int x, int y)
        {
            return _image[x, y];
        }

        public void SetPixel(int x, int y, Colour colour)
        {
            _image[x, y] = colour;
        }

        public void AddLineToImage(Coord p1, Coord p2, Colour line_col)
        {
            var line_list = Point2LineHelper.gimmeLine(p1, p2);

            foreach (var point in line_list)
            {
                this.SetPixel(point.X, point.Y, line_col);  
            }
        }
    }

}