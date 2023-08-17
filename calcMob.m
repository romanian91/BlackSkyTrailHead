function transfer = calcMob(transfer)

% --------------
% Hard coded device parameters

Cap = 1.15E-8;
L = 50;
W = 2000;

% --------------

FilePath = transfer.path;

fid = fopen(FilePath);
c = textscan(fid,'%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s','delimiter',',');
VGCell = c{2};
VDCell = c{3};
IDCell = c{5};

VGCell = VGCell(end-321:end-161);   % Pull the last forward sweep across VG from the file
VDCell = VDCell(end-321:end-161);
IDCell = IDCell(end-321:end-161);

VG = zeros(length(VGCell),1);
VD = zeros(length(VDCell),1);
ID = zeros(length(VDCell),1);

for i = 1:length(VG)
    VG(i) = str2num(VGCell{i});
    VD(i) = str2num(VDCell{i});
    ID(i) = str2num(IDCell{i});
end

% Curve Fitting
C = [50, 2000, 1.15E-08];
FUN = @(X,XDATA) SatMob(X,XDATA,C);
X0 = [0.05, 20];
VGRange = VG(ceil(100*length(VG)/160):end);
IDRange = ID(ceil(100*length(ID)/160):end);
OPTIONS = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
[X,RESNORM] = lsqcurvefit(FUN,X0,VGRange,IDRange,[],[],OPTIONS);

IDfit = SatMob(X,VG,C);
Mobility = X(1);
VT = X(2);

transfer.satMob = Mobility;
transfer.VT = VT;
transfer.IDfit = IDfit;
transfer.VG = VG;
transfer.ID = ID;

% 
% RID = sqrt(abs(ID));
% dRID= diff(RID);
% dVG = diff(VG);
% 
% dIdV = dRID./dVG;
% Mob = 2*L/(W*Cap)*dIdV.^2;

% disp('Mobility:')
% disp(Mobility)
% disp('Threshold Voltage:')
% disp(X(2))
% whos Mob

end

function ID = SatMob(X,XDATA,C)

% X = [µ, Vt]
% XDATA = column vector of VG
% C = [L, W, C];

ID = -C(2)*C(3)/(2*C(1))*X(1)*(XDATA-X(2)).^2;

end

