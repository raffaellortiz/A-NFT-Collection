// Next.js API route support: https://nextjs.org/docs/api-routes/introduction

export default function handler(req, res) {
  const tokenId = req.query.tokenId;
  const name = `Dragon Dev #${tokenId}`;
  const description = "Dragon Dev is a NFT collection fror web3 devs."
  const image = `https://a-nft-collection.vercel.app/cryptodevs/${Number(tokenId) - 1}.svg`;

  return res.json({
    name: name,
    description: description,
    image: image,
  });
}
