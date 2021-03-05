using System;
using System.IO;

namespace weather
{
    class Program
    {
        static void Main(string[] args)
        {
            var max_max = 0.0;
            var min_min = 100000000.0;
            var max_date = "nada";
            var min_date = "zilch";

            using(var reader = new StreamReader(@"C:\Users\Bea\Desktop\dev\euled-up\Week_6_Data_Science_w_CSV\data\weather.csv"))
            {
                while (!reader.EndOfStream)
                {
                    var line = reader.ReadLine();
                    var values = line.Split(',');
                    var date = values[4].Trim(new char[] {'\"'});
                    var max_temp_raw = values[9].Trim(new char[] {'\"'});
                    var min_temp_raw = values[11].Trim(new char[] {'\"'});
                    var max_parse = float.TryParse(max_temp_raw, out float max_temp);
                    var min_parse = float.TryParse(min_temp_raw, out float min_temp);

                    if (max_parse && min_parse)
                    {
                        Console.WriteLine(date);
                        var diff = max_temp - min_temp;
                        Console.WriteLine(diff);
                        if (diff > max_max)
                        {
                            max_max = diff;
                            max_date = date;
                        }
                        else if (diff < min_min)
                        {
                            min_min = diff;
                            min_date = date;
                        }
                    }
                }
            }
            Console.WriteLine(max_date);
            string output_msg = String.Format("Date: {0} has max diff {1:0.00}", max_date, max_max);
            Console.WriteLine(output_msg);

            output_msg = String.Format("Date: {0} has min diff {1:0.00}", min_date, min_min);
            Console.WriteLine(output_msg);
        }
    }
}
