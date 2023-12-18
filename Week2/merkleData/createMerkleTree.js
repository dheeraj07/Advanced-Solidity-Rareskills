const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");
const fs = require("fs");

const values = [
  ["0x0000000000000000000000000000000000000001", "1"],
  ["0x0000000000000000000000000000000000000002", "2"],
  ["0x0000000000000000000000000000000000000003", "3"],
];

const tree = StandardMerkleTree.of(values, ["address", "uint256"]);

console.log("Merkle Root:", tree.root);

fs.writeFileSync("tree.json", JSON.stringify(tree.dump()));
