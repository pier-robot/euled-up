using System;
using System.Collections.Generic;


namespace PointStuff
{
    readonly public struct Coord
        {
            public int X { get; }
            public int Y { get; }
            public Coord(int x, int y)
            {
                this.X = x;
                this.Y = y;
            }
        }

    public static class Point2LineHelper
    {
        public static List<Coord> gimmeLine(Coord p1, Coord p2)
        {
            var x = p1.X;
            var x2= p2.X;
            var y = p1.Y;
            var y2 = p2.Y;

            var coord_list = new List<Coord>();
            // i stole this!
            int w = x2 - x ;
            int h = y2 - y ;
            int dx1 = 0, dy1 = 0, dx2 = 0, dy2 = 0 ;
            if (w<0) dx1 = -1 ; else if (w>0) dx1 = 1 ;
            if (h<0) dy1 = -1 ; else if (h>0) dy1 = 1 ;
            if (w<0) dx2 = -1 ; else if (w>0) dx2 = 1 ;
            int longest = Math.Abs(w) ;
            int shortest = Math.Abs(h) ;
            if (!(longest>shortest)) {
                longest = Math.Abs(h) ;
                shortest = Math.Abs(w) ;
                if (h<0) dy2 = -1 ; else if (h>0) dy2 = 1 ;
                dx2 = 0 ;            
            }
            int numerator = longest >> 1 ;
            for (int i=0;i<=longest;i++) {
                var new_coord = new Coord(x, y);
                coord_list.Add(new_coord);
                numerator += shortest ;
                if (!(numerator<longest)) {
                    numerator -= longest ;
                    x += dx1 ;
                    y += dy1 ;
                } else {
                    x += dx2 ;
                    y += dy2 ;
                }
            }

            return coord_list;
        }
    }
}
