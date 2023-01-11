import { ethers } from "hardhat";

// Helper function to get a random salt
export function getRandomSalt() {
  return ethers.utils.randomBytes(20);
}

// Helper function to strip a bytes32 to an address format
export function stripBytes32ToAddress(bytes: string | undefined) {
  return "0x" + bytes?.substring(26);
}

// Helper function to set all signers used in this test suite
export async function getSignersHelper() {
  const [admin1, admin2, admin3, user1, user2] = await ethers.getSigners();

  return {
    admin1,
    admin2,
    admin3,
    user1,
    user2,
  };
}
