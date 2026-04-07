package model;

public class Role {
    private int roleId;
    private String roleName;
    private String description;
    private String loginUrl;
    private String imagePath;
    private String iconGradient;

    public Role() {
    }

    public Role(int roleId, String roleName, String description, String loginUrl, String imagePath, String iconGradient) {
        this.roleId = roleId;
        this.roleName = roleName;
        this.description = description;
        this.loginUrl = loginUrl;
        this.imagePath = imagePath;
        this.iconGradient = iconGradient;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getLoginUrl() {
        return loginUrl;
    }

    public void setLoginUrl(String loginUrl) {
        this.loginUrl = loginUrl;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public String getIconGradient() {
        return iconGradient;
    }

    public void setIconGradient(String iconGradient) {
        this.iconGradient = iconGradient;
    }
}
