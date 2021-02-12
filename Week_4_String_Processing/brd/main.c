#include <stdio.h> 
#include <stdlib.h> 
#include <stdbool.h> 
#include <string.h>

struct Word_x
{
    // yah i googled the longest length of a standard english word
    char actual_word[45];
    int occurrences;
};
typedef struct Word_x Word;

void append(char* main_str, char new_char)
{
    int length = strlen(main_str);
    main_str[length] = new_char;
    main_str[length+1] = '\0'; 
}

void gimme_first_word(char *input_string, char* first_word, int* actual_buf)
{
    bool start_word = false;
    for (int i = 0; i < strlen(input_string); i++)
    {
        *actual_buf = *actual_buf + 1;
        if (input_string[i] == ' ')
        {
            if (start_word) break;
            else continue;
        }
        else
        {
            start_word = true;
        }
        append(first_word, input_string[i]);
    }
}

void get_rid_of_this_shady_character(char *input_string, char shady, char good)
{
    for (int i = 0; i < strlen(input_string); i++)
    {
        if (input_string[i] == shady)
        {
            input_string[i] = good;
        }
    }
}

void commonest_word(char *input_string)
{

    int word_array_size = 1;
    Word *word_arr = malloc(word_array_size*sizeof(*word_arr));
    if (word_arr == NULL)
    {
        printf("oh god malloc failed\n");
        return;
    }

    char a_word[45] = "";
    int a_word_len = 0;

    gimme_first_word(input_string, a_word, &a_word_len);
    // increment the pointer to remove the first word
    input_string = input_string + a_word_len;
    strcpy(word_arr[0].actual_word, a_word);
    word_arr[0].occurrences = 1;
    Word max_track = {"", 1};
    strcpy(max_track.actual_word, a_word);
    a_word[0] = '\0';
    a_word_len = 0;

    while (input_string[0] != '\0')
    {
        gimme_first_word(input_string, a_word, &a_word_len);

        bool found = false;
        for (int i = 0;i < word_array_size; i++)
        {
            int result = strcmp(word_arr[i].actual_word, a_word);
            if (result == 0)
            {
                found = true;
                word_arr[i].occurrences++;
            }
            if (word_arr[i].occurrences > max_track.occurrences)
            {
                strcpy(max_track.actual_word, word_arr[i].actual_word);
                max_track.occurrences = word_arr[i].occurrences;
            }

        }
        if (!found)
        {
            word_array_size++;
            word_arr = realloc(word_arr, word_array_size*sizeof(*word_arr));
            if (word_arr == NULL)
            {
                printf("oh god realloc failed\n");
                return;
            }
            strcpy(word_arr[word_array_size-1].actual_word, a_word);
            word_arr[word_array_size-1].occurrences = 1;
        }

        // increment the pointer to remove the first word
        input_string = input_string + a_word_len;
        a_word[0] = '\0';
        a_word_len = 0;
    }
    printf("Most word: %s. Times the most: %d\n", max_track.actual_word, max_track.occurrences);
    free(word_arr);

}

void main()
{  
    char input_str[200] = "";
    printf("Please input your beautiful words: ");
    scanf("%[^\n]s", &input_str);

    char first_word[45] = "";
    int first_word_len = 0;
    gimme_first_word(input_str, first_word, &first_word_len);
    printf("First word in the string: %s\n", first_word);

    get_rid_of_this_shady_character(input_str, 'b', 's');
    printf("Gottim boss, new string: %s\n", input_str);
    commonest_word(input_str);

} 