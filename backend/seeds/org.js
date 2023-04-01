const org = require('../models/org');
const { faker } = require('@faker-js/faker');
// const urls = require('./urls');

urls=[
    "https://picsum.photos/id/237/800/300",
     "https://picsum.photos/id/238/800/300",
      "https://picsum.photos/id/239/800/300", "https://picsum.photos/id/240/800/300", "https://picsum.photos/id/241/800/300", "https://picsum.photos/id/242/800/300", "https://picsum.photos/id/243/800/300", "https://picsum.photos/id/244/800/300", "https://picsum.photos/id/245/800/300", "https://picsum.photos/id/246/800/300"]

async function seedOrganizations(numOrganizations) {
    
  const organizations = [];
  for (let i = 0; i < numOrganizations; i++) {
    
    const org = {
      orgPic: { // You can use faker to generate a fake file object here
        fileName: "300",
        url: urls[faker.random.numeric()],
      },
      orgBackgroundPic: { // You can use faker to generate a fake file object here
        fileName: "300",
        url: urls[faker.random.numeric()],
      },
      orgName: faker.company.name(),
      email: faker.internet.email(),
      password: faker.internet.password(),
      phoneNumber: parseInt(faker.phone.imei()),
      bio: faker.lorem.sentence(),
      website: faker.internet.url(),
      socialMedia: faker.internet.url(),
      org_type: parseInt(faker.helpers.arrayElements([0,1, 2])),
      location: faker.address.city(),
      orgEvents: [], // You can add event IDs here
    };
    organizations.push(org);
    
    
}
await new org(
  organizations[0]
).save()    
// console.log(organizations);
// for (let index = 0; index < organizations.length; index++) {
   
// }
}

// Usage:
seedOrganizations(10); // Seed 10 organizations
