var target = Math.floor(Math.random() * 100 + 1)
for(var done = false; !done;) {
    var guess = Math.floor(Number(prompt("Guess a number from 1 to 100!")))
    guess ?
        guess == target ? (alert("Correct!"), done = true) :
            guess > target ?
                alert("Smaller than that.") :
                alert("Larger than that.")
    : alert("Enter only numbers.")
}
