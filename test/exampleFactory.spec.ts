import "@nomicfoundation/hardhat-toolbox";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { IMPLEMENTATION_STORAGE_POSITION } from "../constants/constants";
import {
  DummyImplementation,
  ExampleContract,
  ExampleFactory,
  TransparentUpgradeableProxy,
} from "../typechain-types";
import {
  getRandomSalt,
  getSignersHelper,
  stripBytes32ToAddress,
} from "./helper";

// TODO: Add more details to this test suite
describe("ExampleFactory", function () {
  let factory: ExampleFactory;
  let baseExampleContract: ExampleContract;
  let transparentUpgradeableProxy: TransparentUpgradeableProxy;
  let dummyImplementation: DummyImplementation;
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
    baseExampleContract = await BaseExampleContract.deploy();

    const DummyImplementationContract = await ethers.getContractFactory(
      "DummyImplementation",
    );
    dummyImplementation = await DummyImplementationContract.deploy();

    const TransparentUpgradeableProxyContract = await ethers.getContractFactory(
      "TransparentUpgradeableProxy",
    );
    transparentUpgradeableProxy =
      await TransparentUpgradeableProxyContract.deploy(
        dummyImplementation.address,
        signers.admin1.address,
        Buffer.from(""),
      );

    const Factory = await ethers.getContractFactory("ExampleFactory");
    factory = await Factory.deploy(
      [signers.admin1.address, signers.admin2.address, signers.admin3.address],
      baseExampleContract.address,
    );
  });

  describe("Factory Deployment", () => {
    describe("Clone Deployment", () => {
      it("Clone contract deployed", async () => {
        const salt = getRandomSalt();
        const callData = ethers.utils.defaultAbiCoder.encode(
          ["address[]"],
          [[signers.admin1.address]],
        );
        let tx = await factory.deployDeterministicClone(salt, callData);

        const receipt = await tx.wait();

        const event = receipt.events?.find(
          (ev) => ev.event === "ExampleCloneDeployed",
        );

        const contract = baseExampleContract
          //@ts-ignore
          .attach(event.args[0])
          .connect(signers.admin1);

        expect(contract.address).to.not.be.null;
      });

      it("Clone contract has working function", async () => {
        const salt = getRandomSalt();
        const callData = ethers.utils.defaultAbiCoder.encode(
          ["address[]"],
          [[signers.admin1.address]],
        );
        let tx = await factory.deployDeterministicClone(salt, callData);

        const receipt = await tx.wait();

        const event = receipt.events?.find(
          (ev) => ev.event === "ExampleCloneDeployed",
        );

        const contract = baseExampleContract
          //@ts-ignore
          .attach(event.args[0])
          .connect(signers.admin1);

        const val = await contract.CONTRACT_NAME();

        expect(val).to.equal("Example Contract");
      });
    });

    describe("Proxy Deployment", () => {
      it("Proxy contract deployed", async () => {
        const salt = getRandomSalt();
        const callData = ethers.utils.defaultAbiCoder.encode(
          ["address[]"],
          [[signers.admin1.address]],
        );
        let tx = await factory.deployDeterministicUpgradableProxy(
          salt,
          signers.user1.address,
          callData,
        );

        const receipt = await tx.wait();

        const event = receipt.events?.find(
          (ev) => ev.event === "ExampleUpgradableProxyDeployed",
        );

        const contract = baseExampleContract
          //@ts-ignore
          .attach(event.args[0])
          .connect(signers.admin1);

        expect(contract.address).to.not.be.null;
      });

      it("Proxy contract has working function", async () => {
        const salt = getRandomSalt();
        const callData = ethers.utils.defaultAbiCoder.encode(
          ["address[]"],
          [[signers.admin1.address]],
        );
        let tx = await factory.deployDeterministicUpgradableProxy(
          salt,
          signers.user1.address,
          callData,
        );

        const receipt = await tx.wait();

        const event = receipt.events?.find(
          (ev) => ev.event === "ExampleUpgradableProxyDeployed",
        );

        const contract = baseExampleContract
          //@ts-ignore
          .attach(event.args[0])
          .connect(signers.admin1);

        const val = await contract.CONTRACT_NAME();

        expect(val).to.equal("Example Contract");
      });

      it("Proxy contract is upgradable", async () => {
        const salt = getRandomSalt();
        const callData = ethers.utils.defaultAbiCoder.encode(
          ["address[]"],
          [[signers.admin1.address]],
        );
        let tx = await factory.deployDeterministicUpgradableProxy(
          salt,
          signers.user1.address,
          callData,
        );

        const receipt = await tx.wait();

        const event = receipt.events?.find(
          (ev) => ev.event === "ExampleUpgradableProxyDeployed",
        );

        const contract = transparentUpgradeableProxy
          //@ts-ignore
          .attach(event.args[0])
          .connect(signers.user1);

        const oldImplementation = await signers.user1.provider?.getStorageAt(
          contract.address,
          IMPLEMENTATION_STORAGE_POSITION,
        );
        await contract.upgradeTo(dummyImplementation.address);
        const newImplementation = await signers.user1.provider?.getStorageAt(
          contract.address,
          IMPLEMENTATION_STORAGE_POSITION,
        );

        expect(stripBytes32ToAddress(oldImplementation)).to.equal(
          baseExampleContract.address.toLowerCase(),
        );
        expect(stripBytes32ToAddress(newImplementation)).to.equal(
          dummyImplementation.address.toLowerCase(),
        );
      });
    });
  });
});
