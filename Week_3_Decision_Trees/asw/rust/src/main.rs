struct Node {
    value: u8,
    children: Vec<Option<Node>>,
}

fn main() {

    let x_tree = Node {
        value: 0,
        children: vec![
            Option::None,
            Option::Some(Node {
                value: 3,
                children: vec![],
            }),
        ],
    };
}
