-- Michael Figueiredo
-- 12/5/2014
-- Database Management
-- Design Project SQL Scripts

-- SQL TABLE CREATE STATEMENTS
-------------------------------------------------------------------------------

CREATE TABLE People (
  pID                 char(10) not null,
  firstName           text not null,
  lastName            text not null,
  DOB                 date not null,
 primary key(pID)
);

CREATE TABLE Investors (
  investorID          char(10) not null references People(pID),
 primary key(investorID)
);

CREATE TABLE StockSymbols (
  existingStockSymbols text not null,
 primary key(existingStockSymbols)
);

CREATE TABLE Companies (
  cID                 text not null references StockSymbols(existingStockSymbols),
  companyName         text not null,
  totalNumberOfStocks integer default 0,
  stockPriceUSD       numeric(8,2) default 0.00,
 primary key(cID)
);

CREATE TABLE Insiders (
  insiderID          char(10) not null references Investors(investorID),
  cID                text not null references Companies(cID),
 primary key (insiderID, cID)
);

CREATE TABLE Trades (
  buyer               char(10) not null references Investors(investorID),
  seller              char(10) not null references Investors(investorID),
  dateTime            timestamp not null,
  stockTraded         text not null references Companies(cID),
  qtyStocksTraded     integer not null,
 primary key(buyer, seller, dateTime)
);

CREATE TABLE MoneyInteractions (
  pID                 char(10) not null references People(pID),
  dateTime            timestamp not null,
  MoneyDepositedUSD   numeric(11,2) not null,
 primary key(pID, dateTime)
);

CREATE TABLE Industries (
  industID            char(5) not null,
  industryName        text,
 primary key(industID)
);

CREATE TABLE MarketRelations (
  cID                 text not null references Companies(cID),
  industID            char(5) not null references Industries(industID),
 primary key(cID, industID)
);

CREATE TABLE HistoricalStockPrices (
  cID                 text not null references Companies(cID),
  recordMonth         integer not null check (recordMonth in (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)),
  recordYear          integer not null,
  stockPriceUSD       numeric(11,2) not null,
 primary key(cID, recordMonth, recordYear)
);

CREATE TABLE Brokerages (
  bID                 char(10) not null,
  brokerageName       text not null,
 primary key(bID)
);

CREATE TABLE BrokerClientRelations (
  bID                 char(10) not null references Brokerages(bID),
  pID                 char(10) not null references Investors(investorID),
  brokerTradeFeeUSD   numeric(8,2) not null default 0.00,
 primary key(bID, pID)
);

CREATE TABLE StocksOwned (
  investorID          char(10) not null references Investors(investorID),
  stock               text not null references Companies(cID),
  numberOfStocksOwned integer not null default 0,
 primary key(investorID, stock)
);

-- SQL REPORTS/QUERIES

SELECT inv.investorID, p.firstName, p.lastName, sumStockVals.sum AS TotalStockValueUSD
FROM   Investors inv, 
       People p,
       (SELECT distinct id, sum(stockVal)
        FROM (SELECT p.PID as ID, (so.numberOfStocksOwned * c.stockPriceUSD) AS stockVal
              FROM   StocksOwned so,
                     Companies c,
                     People p
              WHERE  c.cID = so.stock
              AND    p.pID = so.investorID
             ) as stockValuations
        GROUP BY stockvaluations.id
       ) as sumStockVals
 WHERE inv.investorID = p.pID
 AND   sumStockVals.id = p.pID
 ORDER BY inv.investorID ASC;

-- SQL VIEWS
-------------------------------------------------------------------------------

CREATE VIEW CompanyStockHolders AS
    SELECT c.cID AS StockSymbol,
          c.companyName AS Company,
          inv.investorID AS InvestorID,
		  p.lastName AS LastName,
          p.firstName AS FirstName,
		  so.numberOfStocksOwned AS StocksOwned
	FROM  Companies c,
	      Investors inv,
		  People p,
		  StocksOwned so
	WHERE p.pID = inv.investorID
	AND   inv.investorID = so.investorID
	AND   c.cID = so.stock
	ORDER BY c.companyName ASC,
	         p.lastName ASC;
		  
CREATE OR REPLACE VIEW BrokerClients AS
    SELECT b.bID AS BrokerID,
	       b.brokerageName AS BrokerageName,
		   inv.investorID AS InvestorID,
		   p.lastName AS ClientLastName,
		   p.firstName AS ClientFirstName
	FROM   Brokerages b,
	       Investors inv,
		   People p,
		   BrokerClientRelations bcr
	WHERE  p.pID = inv.investorID
	AND    bcr.pID = inv.InvestorID
	AND    b.bID = bcr.bID
	ORDER BY b.brokerageName ASC,
	         p.lastName ASC;
			 
CREATE OR REPLACE VIEW StocksByIndustry AS
    SELECT i.industID AS IndustryID,
           i.industryName AS Industry,
           c.cID AS CompanyID,
           c.companyName AS CompanyName,
           c.stockPriceUSD AS StockValueUSD
    FROM   Industries i,
           Companies c,
           MarketRelations mr
    WHERE  mr.cID = c.cID
    AND    mr.industID = i.industID
    ORDER BY i.industryName ASC,
             c.companyName ASC; 

-- SQL STORED PROCEDURES
-------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION allStockOwners(text, refcursor) returns refcursor as
$$
DECLARE
	stockID    text   := $1;
	outputRef  refcursor := $2;
BEGIN
	OPEN outputRef for
	    SELECT so.investorID,
	           p.firstName,
	           p.lastName,
	           so.numberOfStocksOwned AS StocksOwned,
	           c.totalNumberOfStocks AS StocksInMarket
        FROM   StocksOwned so,
               People p,
               Companies c
        WHERE  so.stock = stockID
        AND    p.pID = so.investorID
        AND    stockID = c.cID;
	RETURN outputRef;
END;
$$
language plpgsql;

--SELECT allStockOwners('RYGC', 'output');
--FETCH ALL FROM output;

CREATE OR REPLACE FUNCTION ageCheck() RETURNS trigger AS
$$
DECLARE
BEGIN
    IF NEW.DOB > (now()::date - 6574) THEN
	    DELETE FROM People
	    WHERE People.pID = NEW.pID;
	    RAISE NOTICE 'AGE RESTRICTION: Client entered is not 18 years of age or older, entry not saved';
    END IF;
    RETURN NEW; 
END;
$$
language plpgsql;

-- SQL TRIGGER STATEMENTS
-------------------------------------------------------------------------------

CREATE TRIGGER implementAgeRestriction 
AFTER INSERT ON People
FOR EACH ROW
EXECUTE PROCEDURE ageCheck();

-- SQL USER STATEMENTS
-------------------------------------------------------------------------------

-- ANALYST User
CREATE USER analyst;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM analyst;
GRANT SELECT ON Companies             TO analyst;
GRANT SELECT ON Industries            TO analyst;
GRANT SELECT ON MarketRelations       TO analyst;
GRANT SELECT ON HistoricalStockPrices TO analyst;
GRANT SELECT ON Brokerages            TO analyst;

-- TradeManager User
CREATE USER TradeManager;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM analyst;
GRANT SELECT, INSERT ON Trades TO TradeManager;
GRANT SELECT, INSERT, UPDATE ON StocksOwned TO TradeManager; 

-- DBAdmin User
CREATE USER DBAdmin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO DBAdmin;

-- Alan User
CREATE USER alan;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO alan;
REVOKE INSERT, UPDATE ON StocksOwned       FROM alan;
REVOKE INSERT, UPDATE ON Trades            FROM alan;
REVOKE INSERT, UPDATE ON MoneyInteractions FROM alan;
	

-- SQL INSERT STATEMENTS - SAMPLE DATA
-------------------------------------------------------------------------------

INSERT INTO People (pID, firstName, lastName, DOB) VALUES
    ('p000000000', 'Mike', 'Figs', '1901-01-01'),
    ('p000000001', 'Teddy', 'Roosevelt', '1858-10-27'),
    ('p000000002', 'Alan', 'Prime', '1000-12-31'),
    ('p000000003', 'Baby', 'NewYear', '1940-01-01'),
    ('p000000004', 'Johnny', 'Moneybags', '1977-04-15'),
    ('p000000005', 'Wendy', 'Ecofriendly', '1985-06-20'),
    ('p000000006', 'Sandra', 'Steel', '1895-05-12'),
    ('p000000007', 'Zeke', 'Techsavvy', '1980-08-05'),
    ('p000000008', 'Harry', 'Hungryman', '1979-03-17'),
    ('p000000009', 'Thomas', 'Thrifty', '1954-07-25');
	
INSERT INTO Investors (investorID) VALUES
    ('p000000000'),
    ('p000000001'),
    ('p000000002'),
    ('p000000003'),
    ('p000000004'),
    ('p000000005'),
    ('p000000006'),
    ('p000000007'),
    ('p000000008');
	
INSERT INTO StockSymbols (existingStockSymbols) VALUES
    ('RCPR'),
    ('APDR'),
    ('CDR'),
    ('RR'),
    ('CB'),
    ('MSFA'),
    ('TBE'),
    ('RYGC');
	
INSERT INTO Companies (cID, companyName, totalNumberOfStocks, stockPriceUSD) VALUES
    ('RCPR', 'Random College Pizza Restaurant', 4000, 9.26),
    ('APDR', 'AlwaysPrepared Diner Restaurant', 10000, 12.74),
    ('CDR', 'Castle Diner Restaurant', 10000, 13.99),
    ('RR', 'Riverside Railroad', 400, 2.13),
    ('CB', 'College Brewery', 20000, 20.45),
    ('MSFA', 'MovieStreamingForAll', 15000, 16.25),
    ('TBE', 'Textbook Emporium', 2000, 3.11),
    ('RYGC', 'Recycle-Your-Goods Center', 8000, 11.11);

INSERT INTO Insiders (insiderID, cID) VALUES
    ('p000000000', 'CDR'),
    ('p000000000', 'TBE'),
    ('p000000001', 'RR'),
    ('p000000002', 'TBE'),
    ('p000000004', 'CB'),
    ('p000000005', 'RYGC');
	
INSERT INTO Trades (buyer, seller, dateTime, stockTraded, qtyStocksTraded) VALUES
    ('p000000003', 'p000000005', '2014-12-01 08:43:52', 'RYGC', 50),
    ('p000000000', 'p000000004', '2014-12-01 09:15:26', 'CB', 200),
    ('p000000002', 'p000000008', '2014-07-12 11:11:11', 'CDR', 125),
    ('p000000006', 'p000000001', '2014-07-12 14:06:30', 'RR', 16),
    ('p000000004', 'p000000007', '2014-07-12 21:12:00', 'MSFA', 2000);
	
INSERT INTO MoneyInteractions (pID, dateTime, moneyDepositedUSD) VALUES
    ('p000000002', '2014-11-15 00:00:01', 50000.00),
    ('p000000004', '2014-11-17 09:22:45', 26.17),
    ('p000000001', '2014-11-17 11:32:59', 1250.50),
    ('p000000000', '2014-11-19 16:08:31', 450.00),
    ('p000000001', '2014-11-25 04:15:19', -250.50);
	
INSERT INTO Industries (industID, industryName) VALUES
    ('i0000', 'Food/Drink'),
    ('i0001', 'Entertainment/Media'),
    ('i0002', 'Ecological'),
    ('i0003', 'Transportation'),
    ('i0004', 'Educational'),
    ('i0005', 'World Domination');
	
INSERT INTO MarketRelations (cID, industID) VALUES
    ('RCPR', 'i0000'),
    ('APDR', 'i0000'),
    ('CDR', 'i0000'),
    ('CB', 'i0000'),
    ('RR', 'i0003'),
    ('MSFA', 'i0001'),
    ('TBE', 'i0004'),
    ('RYGC', 'i0002'),
    ('RYGC', 'i0005');
	
INSERT INTO HistoricalStockPrices (cID, recordMonth, recordYear, stockPriceUSD) VALUES
    ('RCPR', 8, 2014, 2.05),
    ('RCPR', 9, 2014, 8.75),
    ('APDR', 8, 2014, 4.13),
    ('APDR', 9, 2014, 11.82),
    ('CDR', 8, 2014, 4.26),
    ('CDR', 9, 2014, 10.48),
    ('RR', 8, 2014, 0.99),
    ('RR', 9, 2014, 1.00),
    ('CB', 8, 2014, 15.18),
    ('CB', 9, 2014, 24.63),
    ('MSFA', 8, 2014, 13.75),
    ('MSFA', 9, 2014, 13.75),
    ('TBE', 8, 2014, 51.03),
    ('TBE', 9, 2014, 4.29),
    ('RYGC', 8, 2014, 17.94),
    ('RYGC', 9, 2014, 18.67);
	
INSERT INTO Brokerages (bID, brokerageName) VALUES
    ('b000000000', 'Plumber Bros.'),
    ('b000000001', 'Wallace, Wallace & Wallace'),
    ('b000000002', 'Your Money Is Our Money Inc.'),
    ('b000000003', 'Responsible Money Handlers'),
    ('b000000004', 'The Good Guys'),
    ('b000000005', 'Green is Good');
	
INSERT INTO BrokerClientRelations (bID, pID, brokerTradeFeeUSD) VALUES
    ('b000000004', 'p000000001', 4.25),
    ('b000000003', 'p000000004', 3.15),
    ('b000000001', 'p000000007', 6.18),
    ('b000000002', 'p000000003', 10.75);
	
INSERT INTO StocksOwned (investorID, stock, numberOfStocksOwned) VALUES
    ('p000000003', 'RYGC', 123),
    ('p000000000', 'CB', 2000),
    ('p000000002', 'CDR', 125),
    ('p000000006', 'RR', 80),
    ('p000000004', 'MSFA', 2000),
    ('p000000002', 'CB', 155),
    ('p000000001', 'RR', 320),
    ('p000000004', 'TBE', 750),
    ('p000000008', 'RCPR', 1725),
    ('p000000005', 'RYGC', 726),
    ('p000000007', 'APDR', 2684);
	
