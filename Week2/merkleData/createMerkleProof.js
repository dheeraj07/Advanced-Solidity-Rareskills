const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");
const fs = require("fs");

const tree = StandardMerkleTree.load(JSON.parse(fs.readFileSync("tree.json")));

for (const [i, v] of tree.entries()) {
  if (v[0] === "0x0000000000000000000000000000000000000001") {
    const proof = tree.getProof(i);
    console.log("Value:", v);
    console.log("Proof:", proof);
  }
}
