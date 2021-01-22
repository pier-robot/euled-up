using System;

namespace guess_no_w_feedback
{
    class Program
    {


        static void Main(string[] args)
        {
            // consts
            int upper_limit = 100;
            int lower_limit = 1;

            Random rng = new Random();
            int chosen_no = rng.Next(lower_limit - 1, upper_limit + 1);

            string greeting = string.Format("Hihi! Please guess a number between {0} and {1}:", lower_limit, upper_limit);

            Console.WriteLine(greeting);
            bool guess_again = true;

            while (guess_again)
            {
                string user_input = Console.ReadLine();
                // find out wtf
                var is_num = int.TryParse(user_input, out int user_num);
                if (is_num)
                {
                    if (user_num < lower_limit || user_num > upper_limit)
                    {
                        Console.WriteLine("Your number isn't in the given range, guess again.");
                        continue;
                    }

                    string message_descriptor = "higher than";
                    if (user_num < chosen_no)
                        message_descriptor = "lower than"; 
                    else if (user_num == chosen_no)
                    {
                        message_descriptor = "the same as";
                        guess_again = false;
                    }
                    string output_msg = string.Format("Your guess is {0} the number I've thought of.", message_descriptor);
                    Console.WriteLine(output_msg);

                    if (!guess_again)
                    {
                        Console.WriteLine("You have solved my number riddle!");
                    }

                }
                else
                {
                    Console.WriteLine("This isn't a number so I can't do anything with that, try again.");
                }
            }
        }
    }
}
