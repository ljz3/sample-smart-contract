import "@nomicfoundation/hardhat-toolbox";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { ExampleContract, ExampleFactory } from "../typechain-types";
import { getSignersHelper } from "./helper";

// TODO: Complete these test cases
describe("ExampleContract", function () {
  // let exampleContract: ExampleContract;
  let factory: ExampleFactory;

  let signers: {
    admin1: SignerWithAddress;
    admin2: SignerWithAddress;
    admin3: SignerWithAddress;
    user1: SignerWithAddress;
    user2: SignerWithAddress;
  };

  before(async function () {
    signers = { ...(await getSignersHelper()) };
  });

  beforeEach(async function () {
    const BaseExampleContract = await ethers.getContractFactory(
      "ExampleContract",
    );
    const baseExampleContract = await BaseExampleContract.deploy();

    const Factory = await ethers.getContractFactory("ExampleFactory");
    factory = await Factory.deploy(
      [signers.admin1.address, signers.admin2.address, signers.admin3.address],
      baseExampleContract.address,
    );
  });

  describe("Initializer", () => {
    it("Allows setting zero admins", async () => {
      // let res = await exampleContract.initialize(
      //   ethers.utils.defaultAbiCoder.encode(["address[]"], [[]]),
      // );

      // console.log("res", res);
    });

    it("Clone contract has working function", async () => {});
  });
});
